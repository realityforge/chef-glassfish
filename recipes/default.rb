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

include_recipe 'java'

directory node['glassfish']['base_dir'] do
  mode '0755'
  owner node['glassfish']['user']
  group node['glassfish']['group']
end

group node['glassfish']['group'] do
end

user node['glassfish']['user'] do
  comment 'GlassFish Application Server'
  gid node['glassfish']['group']
  home node['glassfish']['base_dir']
  shell '/bin/bash'
  system true
end

a = archive 'glassfish' do
  url node['glassfish']['package_url']
  version node['glassfish']['version']
  owner node['glassfish']['user']
  group node['glassfish']['group']
  extract_action 'unzip_and_strip_dir'
end

exists_at_run_start = ::File.exist?(a.target_directory)

node.override['glassfish']['install_dir'] = a.target_directory

directory "#{node['glassfish']['install_dir']}/glassfish/domains/domain1" do
  recursive true
  action :delete
  not_if {exists_at_run_start}
end

if node['glassfish']['remove_domains_dir_on_install']
  # We remove the domains directory on initial install as it is expected that they will need to be
  # recreated due to upgrade in glassfish version
  directory node['glassfish']['domains_dir'] do
    recursive true
    action :nothing
    not_if {exists_at_run_start}
  end
end
