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

group node['glassfish']['group'] do
end

user node['glassfish']['user'] do
  comment 'GlassFish Application Server'
  gid node['glassfish']['group']
  home node['glassfish']['base_dir']
  shell '/bin/bash'
  system true
end

package_url = node['glassfish']['package_url']
base_package_filename = File.basename(package_url)
cached_package_filename = "#{Chef::Config[:file_cache_path]}/#{base_package_filename}"
check_proc = Proc.new { ::File.exists?(node['glassfish']['base_dir']) }

remote_file cached_package_filename do
  not_if { check_proc.call }
  source package_url
  mode '0600'
  action :create_if_missing
end

package 'unzip'

bash 'unpack_glassfish' do
  not_if { check_proc.call }
  code <<-EOF
rm -rf /tmp/glassfish
mkdir /tmp/glassfish
cd /tmp/glassfish
unzip -qq #{cached_package_filename}
mkdir -p #{File.dirname(node['glassfish']['base_dir'])}
mv glassfish3 #{node['glassfish']['base_dir']}
chown -R #{node['glassfish']['user']} #{node['glassfish']['base_dir']}
chgrp -R #{node['glassfish']['group']} #{node['glassfish']['base_dir']}
chmod -R 0770 #{node['glassfish']['base_dir']}/bin/
chmod -R 0770 #{node['glassfish']['base_dir']}/glassfish/bin/
rm -rf #{node['glassfish']['base_dir']}/glassfish/domains/domain1
test -d #{node['glassfish']['base_dir']}
EOF
end

cookbook_file "#{node['glassfish']['base_dir']}/glassfish/lib/templates/domain.xml" do
  source 'domain.xml'
  owner node['glassfish']['user']
  group node['glassfish']['group']
  mode 0644
end
