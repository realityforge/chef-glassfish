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

  command = []
  command << 'create-javamail-resource'
  command << '--mailhost' << new_resource.mailhost
  command << '--mailuser' << new_resource.mailuser
  command << '--fromaddress' << new_resource.fromaddress
  command << '--storeprotocol' << new_resource.storeprotocol if new_resource.storeprotocol
  command << '--storeprotocolclass' << new_resource.storeprotocolclass if new_resource.storeprotocolclass
  command << '--transprotocol' << new_resource.transprotocol if new_resource.transprotocol
  command << '--transprotocolclass' << new_resource.transprotocolclass if new_resource.transprotocolclass
  command << '--property' << encode_parameters(new_resource.properties) unless new_resource.properties.empty?
  command << '--description' << "'#{new_resource.description}'" if new_resource.description
  command << "--debug=#{new_resource.debug}" if new_resource.debug
  command << "--enabled=#{new_resource.enabled}" if new_resource.enabled
  command << asadmin_target_flag
  command << new_resource.jndi_name

  bash "asadmin_create-javamail-resource #{new_resource.jndi_name}" do
    not_if "#{asadmin_command('list-javamail-resources')} #{new_resource.target} | grep -F -x -- '#{new_resource.jndi_name}'", :timeout => 150
    timeout 150
    user new_resource.system_user
    group new_resource.system_group
    code asadmin_command(command.join(' '))
  end
end

action :delete do
  command = []
  command << 'delete-javamail-resource'
  command << asadmin_target_flag
  command << new_resource.jndi_name

  bash "asadmin_delete-javamail-resource #{new_resource.jndi_name}" do
    only_if "#{asadmin_command('list-javamail-resources')} #{new_resource.target} | grep -F -x -- '#{new_resource.jndi_name}'", :timeout => 150
    timeout 150
    user new_resource.system_user
    group new_resource.system_group
    code asadmin_command(command.join(' '))
  end
end
