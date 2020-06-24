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
  args << 'create-connector-resource'
  args << '--poolname' << new_resource.poolname
  args << '--property' << encode_parameters(new_resource.properties) unless new_resource.properties.empty?
  args << '--description' << "\"#{new_resource.description}\"" if new_resource.description
  args << '--objecttype' << new_resource.objecttype if new_resource.objecttype
  args << "--enabled=#{new_resource.enabled}" if new_resource.enabled
  args << asadmin_target_flag
  args << new_resource.name

  execute "asadmin_create-connector-resource #{new_resource.name}" do
    timeout node['glassfish']['asadmin']['timeout'] + 5
    user new_resource.system_user unless node.windows?
    group new_resource.system_group unless node.windows?
    command asadmin_command(args.join(' '))
    filter = pipe_filter(new_resource.name, regexp: false, line: true)
    not_if "#{asadmin_command('list-connector-resources')} | #{filter}", timeout: node['glassfish']['asadmin']['timeout'] + 5
  end
end

action :delete do
  args = []
  args << 'delete-connector-resource'
  args << asadmin_target_flag
  args << new_resource.name

  execute "asadmin_delete-connector-resource #{new_resource.name}" do
    timeout node['glassfish']['asadmin']['timeout'] + 5
    user new_resource.system_user unless node.windows?
    group new_resource.system_group unless node.windows?
    command asadmin_command(args.join(' '))
    filter = pipe_filter(new_resource.name, regexp: false, line: true)
    only_if "#{asadmin_command('list-connector-resources')} | #{filter}", timeout: node['glassfish']['asadmin']['timeout'] + 5
  end
end
