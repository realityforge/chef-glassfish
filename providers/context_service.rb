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
  command << 'create-context-service'
  command << asadmin_target_flag

  command << '--enabled' << new_resource.enabled
  command << '--contextinfoenabled' << new_resource.contextinfoenabled
  command << '--contextinfo' << new_resource.contextinfo
  command << '--description' << "\"#{new_resource.description}\""
  command << new_resource.jndi_name

  bash "asadmin_create-context-service #{new_resource.jndi_name}" do
    not_if "#{asadmin_command('list-context-services')} #{new_resource.target} | grep -F -x -- '#{new_resource.jndi_name}'", :timeout => 150
    timeout 150
    user new_resource.system_user
    group new_resource.system_group
    code asadmin_command(command.join(' '))
  end

  properties = {
    'context-info' => new_resource.contextinfo,
    'context-info-enabled' => new_resource.contextinfoenabled,
    'enabled' => new_resource.enabled,
    'description' => (new_resource.description || ''),
    #deployment-order=100
  }

  properties.each_pair do |key, value|
    variable = "resources.context-service.#{new_resource.jndi_name}.#{key}"
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
  command << 'delete-context-service'
  command << asadmin_target_flag
  command << new_resource.jndi_name

  bash "asadmin_delete-context-service #{new_resource.jndi_name}" do
    only_if "#{asadmin_command('list-context-services')} #{new_resource.target} | grep -F -x -- '#{new_resource.jndi_name}'", :timeout => 150
    timeout 150
    user new_resource.system_user
    group new_resource.system_group
    code asadmin_command(command.join(' '))
  end
end
