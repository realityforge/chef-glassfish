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
  args << 'create-resource-adapter-config'

  args << '--threadpoolid' << new_resource.threadpoolid if new_resource.threadpoolid
  args << '--objecttype' << new_resource.objecttype if new_resource.objecttype

  args << '--property' << encode_parameters(new_resource.properties) unless new_resource.properties.empty?
  args << new_resource.resource_adapter_name

  execute "asadmin_create-resource-adapter-config #{new_resource.resource_adapter_name}" do
    not_if "#{asadmin_command('list-resource-adapter-configs')} | grep -F -x -- '#{new_resource.resource_adapter_name}'", :timeout => node['glassfish']['asadmin']['timeout'] + 5
    timeout node['glassfish']['asadmin']['timeout'] + 5
    user new_resource.system_user unless node['os'] == 'windows'
    group new_resource.system_group unless node['os'] == 'windows'
    command asadmin_command(args.join(' '))
  end
end

action :delete do
  command = []
  command << 'delete-resource-adapter-config'
  command << new_resource.resource_adapter_name

  execute "asadmin_delete-resource-adapter-config #{new_resource.resource_adapter_name}" do
    only_if "#{asadmin_command('list-resource-adapter-configs')} | grep -F -x -- '#{new_resource.resource_adapter_name}'", :timeout => node['glassfish']['asadmin']['timeout'] + 5
    timeout node['glassfish']['asadmin']['timeout'] + 5
    user new_resource.system_user unless node['os'] == 'windows'
    group new_resource.system_group unless node['os'] == 'windows'
    command asadmin_command(command.join(' '))
  end
end
