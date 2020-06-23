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
  args << 'create-javamail-resource'
  args << '--mailhost' << new_resource.mailhost
  args << '--mailuser' << new_resource.mailuser
  args << '--fromaddress' << new_resource.fromaddress
  args << '--storeprotocol' << new_resource.storeprotocol if new_resource.storeprotocol
  args << '--storeprotocolclass' << new_resource.storeprotocolclass if new_resource.storeprotocolclass
  args << '--transprotocol' << new_resource.transprotocol if new_resource.transprotocol
  args << '--transprotocolclass' << new_resource.transprotocolclass if new_resource.transprotocolclass
  args << '--property' << encode_parameters(new_resource.properties) unless new_resource.properties.empty?
  args << '--description' << "\"#{new_resource.description}\"" if new_resource.description
  args << "--debug=#{new_resource.debug}" if new_resource.debug
  args << "--enabled=#{new_resource.enabled}" if new_resource.enabled
  args << asadmin_target_flag
  args << new_resource.jndi_name

  execute "asadmin_create-javamail-resource #{new_resource.jndi_name}" do
    timeout node['glassfish']['asadmin']['timeout'] + 5
    user new_resource.system_user unless node.windows?
    group new_resource.system_group unless node.windows?
    command asadmin_command(args.join(' '))
    filter = pipe_filter(new_resource.jndi_name, regexp: false, line: true)
    not_if "#{asadmin_command('list-javamail-resources')} #{new_resource.target} | #{filter}", timeout: node['glassfish']['asadmin']['timeout'] + 5
  end
end

action :delete do
  args = []
  args << 'delete-javamail-resource'
  args << asadmin_target_flag
  args << new_resource.jndi_name

  execute "asadmin_delete-javamail-resource #{new_resource.jndi_name}" do
    timeout node['glassfish']['asadmin']['timeout'] + 5
    user new_resource.system_user unless node.windows?
    group new_resource.system_group unless node.windows?
    command asadmin_command(args.join(' '))
    filter = pipe_filter(new_resource.jndi_name, regexp: false, line: true)
    only_if "#{asadmin_command('list-javamail-resources')} #{new_resource.target} | #{filter}", timeout: node['glassfish']['asadmin']['timeout'] + 5
  end
end
