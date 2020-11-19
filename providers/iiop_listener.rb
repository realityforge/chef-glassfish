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
  args << 'create-iiop-listener'
  args << asadmin_target_flag
  args << '--listeneraddress' << new_resource.listeneraddress if new_resource.listeneraddress
  args << '--iiopport' << new_resource.iiopport
  args << '--securityenabled' << new_resource.securityenabled
  args << '--enabled' << new_resource.enabled
  args << '--property' << encode_parameters(new_resource.properties) unless new_resource.properties.empty?

  args << new_resource.iioplistener_id

  execute "asadmin_create-iiop-listener #{new_resource.iioplistener_id}" do
    timeout node['glassfish']['asadmin']['timeout'] + 5
    user new_resource.system_user unless node.windows?
    group new_resource.system_group unless node.windows?
    command asadmin_command(args.join(' '))
    filter = pipe_filter(new_resource.iioplistener_id, regexp: false, line: true)
    not_if "#{asadmin_command('list-iiop-listeners')} #{new_resource.target} | #{filter}", timeout: node['glassfish']['asadmin']['timeout'] + 5
  end

  properties = new_resource.properties.dup.merge(
    'address' => (new_resource.listeneraddress || '0.0.0.0'),
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
  args = []
  args << 'delete-iiop-listener'
  args << asadmin_target_flag
  args << new_resource.iioplistener_id

  execute "asadmin_delete_iiop-listener #{new_resource.iioplistener_id}" do
    timeout node['glassfish']['asadmin']['timeout'] + 5
    user new_resource.system_user unless node.windows?
    group new_resource.system_group unless node.windows?
    command asadmin_command(args.join(' '))
    filter = pipe_filter(new_resource.iioplistener_id, regexp: false, line: true)
    only_if "#{asadmin_command('list-iiop-listeners')} #{new_resource.target} | #{filter}", timeout: node['glassfish']['asadmin']['timeout'] + 5
  end
end
