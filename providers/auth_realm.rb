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
  args << 'create-auth-realm'
  args << asadmin_target_flag
  args << '--classname' << new_resource.classname
  properties = new_resource.properties.dup
  properties['jaas-context'] = new_resource.jaas_context if new_resource.jaas_context
  properties['assign-groups'] = new_resource.assign_groups if new_resource.assign_groups
  args << '--property' << encode_parameters(properties)
  args << new_resource.name

  execute "asadmin_create_auth_realm #{new_resource.name}" do
    timeout node['glassfish']['asadmin']['timeout'] + 5
    user new_resource.system_user unless node.windows?
    group new_resource.system_group unless node.windows?
    command asadmin_command(args.join(' '))
    not_if "#{asadmin_command('list-auth-realms')} #{new_resource.target} | #{pipe_filter(new_resource.name, regexp: false, line: true)}", timeout: node['glassfish']['asadmin']['timeout'] + 5
  end

  properties.each_pair do |key, value|
    variable = "configs.config.server-config.security-service.auth-realm.#{new_resource.name}.property.#{key}"
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
  args = []
  args << 'delete-auth-realm'
  args << asadmin_target_flag
  args << new_resource.name

  execute "asadmin_delete_auth_realm #{new_resource.name}" do
    timeout node['glassfish']['asadmin']['timeout'] + 5
    user new_resource.system_user unless node.windows?
    group new_resource.system_group unless node.windows?
    command asadmin_command(args.join(' '))
    filter = pipe_filter(new_resource.name, regexp: false, line: true)
    only_if "#{asadmin_command('list-auth-realms')} #{new_resource.target} | #{filter}", timeout: node['glassfish']['asadmin']['timeout'] + 5
  end
end
