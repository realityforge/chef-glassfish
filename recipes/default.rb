#
# Copyright Peter Donald
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

=begin
#<
Downloads, and extracts the glassfish binaries, creates the glassfish user and group.

Does not create any Application Server or Message Broker instances. This recipe is not
typically included directly but is included transitively through either <code>glassfish::attribute_driven_domain</code>
or <code>glassfish::attribute_driven_mq</code>.
#>
=end

# Scans Glassfish's binary for endorsed JARs and returns a list of filenames
def gf_scan_existing_binary_endorsed_jars(install_dir)
  jar_extensions = ['.jar']
  gf_binary_endorsed_dir = install_dir + '/glassfish/lib/endorsed'
  if Dir.exist?(gf_binary_endorsed_dir)
    existing_binary_endorsed_jars = Dir.entries(gf_binary_endorsed_dir).reject { |f| File.directory?(f) || !jar_extensions.include?(File.extname(f)) }
  else
    existing_binary_endorsed_jars = []
  end
  existing_binary_endorsed_jars
end

include_recipe 'glassfish::derive_version'
include_recipe 'java'

group node['glassfish']['group'] do
  not_if "getent group #{node['glassfish']['group']}"
  not_if { node['install']['external_users'].casecmp("true") == 0 }
end

user node['glassfish']['user'] do
  comment 'GlassFish Application Server'
  gid node['glassfish']['group']
  home node['glassfish']['base_dir']
  shell '/bin/bash'
  system true
  not_if "getent passwd #{node['glassfish']['user']}"
  not_if { node['install']['external_users'].casecmp("true") == 0 }
end

directory node['glassfish']['base_dir'] do
  recursive true
  mode '0755'
  owner node['glassfish']['user']
  group node['glassfish']['group']
end

a = glassfish_archive 'glassfish' do
  prefix node['glassfish']['install_dir']
  url node['glassfish']['package_url']
  version node['glassfish']['version']
  owner node['glassfish']['user']
  group node['glassfish']['group']
  action 'unzip_and_strip_dir'
end

exists_at_run_start = ::File.exist?(a.target_directory)

node.override['glassfish']['install_dir'] = a.current_directory

template "#{node['glassfish']['install_dir']}/glassfish/config/asenv.conf" do
  source 'asenv.conf.erb'
  mode '0600'
  cookbook 'glassfish'
  owner node['glassfish']['user']
  group node['glassfish']['group']
end

directory "#{node['glassfish']['install_dir']}/glassfish/domains/domain1" do
  recursive true
  action :delete
  not_if { exists_at_run_start }
end

if node['glassfish']['remove_domains_dir_on_install']
  # We remove the domains directory on initial install as it is expected that they will need to be
  # recreated due to upgrade in glassfish version
  directory node['glassfish']['domains_dir'] do
    recursive true
    action :nothing
    not_if { exists_at_run_start }
  end
end

# Install/delete endorsed JAR files into Glassfish's binary to be used thourgh the Java Endorsed mechanism.
# see: https://docs.oracle.com/javase/7/docs/technotes/guides/standards/
gf_binary_endorsed_dir = node['glassfish']['install_dir'] + File::Separator + 'glassfish' + File::Separator + 'lib' + File::Separator + 'endorsed'

# Delete unnecessary binary endorsed jar files
gf_scan_existing_binary_endorsed_jars(node['glassfish']['install_dir']).each do |file_name|
  next if node['glassfish']['endorsed'] && node['glassfish']['endorsed'][file_name]
  Chef::Log.info "Deleting binary endorsed jar file - #{file_name}"
  file gf_binary_endorsed_dir + File::Separator + file_name do
    action :delete
  end
end

# Install missing binary endorsed jar files
if node['glassfish']['endorsed']
  node['glassfish']['endorsed'].each_pair do |file_name, value|
    url = value['url']
    Chef::Log.info "Installing binary endorsed jar file - #{file_name}"
    target_file = gf_binary_endorsed_dir + File::Separator + file_name
    remote_file target_file do
      source url
      mode '0600'
      owner node['glassfish']['user']
      group node['glassfish']['group']
      action :create
      not_if { ::File.exist?(target_file) }
    end
  end
end
