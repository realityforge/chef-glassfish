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

action :create do
  command = []
  command << "create-auth-realm"
  command << "--target" << new_resource.target if new_resource.target
  command << "--classname" << new_resource.classname
  command << "--target" << new_resource.target if new_resource.target
  properties = new_resource.properties.dup
  properties['jaas-context'] = new_resource.jaas_context
  properties['assign-groups'] = new_resource.assign_groups if new_resource.assign_groups
  command << "--property" << "'#{properties.collect{|k,v| "#{k}=#{v.gsub(':','\:')}"}.join(":")}'"
  command << new_resource.name

  bash "asadmin_create_auth_realm #{new_resource.name}" do
    not_if "#{asadmin_command('list-auth-realms')} | grep -x -- '#{new_resource.name}'"
    user node['glassfish']['user']
    group node['glassfish']['group']
    code asadmin_command(command.join(' '))
  end
end

  end
end
