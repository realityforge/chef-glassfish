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
  args << 'create-context-service'
  args << asadmin_target_flag

  args << '--enabled' << new_resource.enabled
  args << '--contextinfoenabled' << new_resource.contextinfoenabled
  args << '--contextinfo' << new_resource.contextinfo
  args << '--description' << "\"#{new_resource.description}\""
  args << new_resource.jndi_name

  execute "asadmin_create-context-service #{new_resource.jndi_name}" do
    # execute should wait for asadmin to time out first, if it doesn't because of some problem, execute should time out eventually
    timeout node['glassfish']['asadmin']['timeout'] + 5

    user new_resource.system_user unless node.windows?
    group new_resource.system_group unless node.windows?
    command asadmin_command(args.join(' '))

    filter = pipe_filter(new_resource.jndi_name, regexp: false, line: true)
    not_if "#{asadmin_command('list-context-services')} #{new_resource.target} | #{filter}", :timeout => node['glassfish']['asadmin']['timeout'] + 5
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
  args = []
  args << 'delete-context-service'
  args << asadmin_target_flag
  args << new_resource.jndi_name

  execute "asadmin_delete-context-service #{new_resource.jndi_name}" do
    # execute should wait for asadmin to time out first, if it doesn't because of some problem, execute should time out eventually
    timeout node['glassfish']['asadmin']['timeout'] + 5

    user new_resource.system_user unless node.windows?
    group new_resource.system_group unless node.windows?
    command asadmin_command(args.join(' '))

    filter = pipe_filter(new_resource.jndi_name, regexp: false, line: true)
    only_if "#{asadmin_command('list-context-services')} #{new_resource.target} | #{filter}", :timeout => node['glassfish']['asadmin']['timeout'] + 5
  end
end
