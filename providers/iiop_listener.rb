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
  command << 'create-iiop-listener'
  command << asadmin_target_flag
  if new_resource.listeneraddress
    command << '--listeneraddress' << new_resource.listeneraddress
  end
  command << '--iiopport' << new_resource.iiopport
  command << '--securityenabled' << new_resource.securityenabled
  command << '--enabled' << new_resource.enabled
  command << '--property' << encode_parameters(new_resource.properties) unless new_resource.properties.empty?

  command << new_resource.iioplistener_id

  bash "asadmin_create-iiop-listener #{new_resource.iioplistener_id}" do
    not_if "#{asadmin_command('list-iiop-listeners')} #{new_resource.target} | grep -F -x -- '#{new_resource.iioplistener_id}'", :timeout => 150
    timeout 150
    user new_resource.system_user
    group new_resource.system_group
    code asadmin_command(command.join(' '))
  end

  properties = new_resource.properties.dup.merge(
    'address' => new_resource.listeneraddress ? new_resource.listeneraddress : '0.0.0.0',
    'enabled' => new_resource.enabled,
    'port' => new_resource.iiopport,
    'security-enabled' => new_resource.securityenabled
  )

  properties.each_pair do |key, value|
    variable = "configs.config.server-config.iiop-service.iiop-listener.#{new_resource.iioplistener_id}.#{key}"
    glassfish_property "#{variable}=#{value}" do
      domain_name new_resource.domain_name
      admin_port new_resource.admin_port
      username new_resource.username
      password_file new_resource.password_file
      secure new_resource.secure
      key variable
      value value.to_s
    end
  end
end

action :delete do
  command = []
  command << 'delete-iiop-listener'
  command << asadmin_target_flag
  command << new_resource.iioplistener_id

  bash "asadmin_delete_iiop-listener #{new_resource.iioplistener_id}" do
    only_if "#{asadmin_command('list-iiop-listeners')} #{new_resource.target} | grep -F -x -- '#{new_resource.iioplistener_id}'", :timeout => 150
    timeout 150
    user new_resource.system_user
    group new_resource.system_group
    code asadmin_command(command.join(' '))
  end
end
