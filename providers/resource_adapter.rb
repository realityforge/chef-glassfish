#
# Copyright:: Peter Donald
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

action :create do
  args = []
  args << 'create-resource-adapter-config'

  args << '--threadpoolid' << new_resource.threadpoolid if new_resource.threadpoolid
  args << '--objecttype' << new_resource.objecttype if new_resource.objecttype

  args << '--property' << encode_parameters(new_resource.properties) unless new_resource.properties.empty?
  args << new_resource.resource_adapter_name

  execute "asadmin_create-resource-adapter-config #{new_resource.resource_adapter_name}" do
    timeout node['glassfish']['asadmin']['timeout'] + 5
    user new_resource.system_user unless node.windows?
    group new_resource.system_group unless node.windows?
    command asadmin_command(args.join(' '))
    filter = pipe_filter(new_resource.resource_adapter_name, regexp: false, line: true)
    not_if "#{asadmin_command('list-connector-connection-pools')} | #{filter}", timeout: node['glassfish']['asadmin']['timeout'] + 5
  end
end

action :delete do
  args = []
  args << 'delete-resource-adapter-config'
  args << new_resource.resource_adapter_name

  execute "asadmin_delete-resource-adapter-config #{new_resource.resource_adapter_name}" do
    timeout node['glassfish']['asadmin']['timeout'] + 5
    user new_resource.system_user unless node.windows?
    group new_resource.system_group unless node.windows?
    command asadmin_command(args.join(' '))
    filter = pipe_filter(new_resource.resource_adapter_name, regexp: false, line: true)
    only_if "#{asadmin_command('list-connector-connection-pools')} | #{filter}", timeout: node['glassfish']['asadmin']['timeout'] + 5
  end
end
