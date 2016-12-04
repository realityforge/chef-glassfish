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

include Chef::Asadmin

use_inline_resources

action :create do

  args = []
  args << 'create-admin-object'
  args << '--raname' << new_resource.raname
  args << '--restype' << new_resource.restype
  args << '--property' << encode_parameters(new_resource.properties) unless new_resource.properties.empty?
  args << '--description' << "'#{new_resource.description}'" if new_resource.description
  args << '--classname' << new_resource.classname if new_resource.classname
  args << "--enabled=#{new_resource.enabled}" if new_resource.enabled
  args << asadmin_target_flag
  args << new_resource.name

  execute "asadmin_create-admin-object #{new_resource.name}" do
    not_if "#{asadmin_command('list-admin-objects')} #{new_resource.target} | grep -F -x -- '#{new_resource.name}'", :timeout => node['glassfish']['asadmin']['timeout'] + 5
    timeout node['glassfish']['asadmin']['timeout'] + 5
    user new_resource.system_user unless node['os'] == 'windows'
    group new_resource.system_group unless node['os'] == 'windows'
    command asadmin_command(args.join(' '))
  end
end

action :delete do
  args = []
  args << 'delete-admin-object'
  args << asadmin_target_flag
  args << new_resource.name

  execute "asadmin_delete-admin-object #{new_resource.name}" do
    only_if "#{asadmin_command('list-admin-objects')} #{new_resource.target} | grep -F -x -- '#{new_resource.name}'", :timeout => node['glassfish']['asadmin']['timeout'] + 5
    timeout node['glassfish']['asadmin']['timeout'] + 5
    user new_resource.system_user unless node['os'] == 'windows'
    group new_resource.system_group unless node['os'] == 'windows'
    command asadmin_command(args.join(' '))
  end
end
