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

action :set do
  command = []
  command << 'set-web-env-entry'
  command << '--name' << new_resource.name
  command << '--type' << new_resource.type
  command << '--description' << "'#{new_resource.description}'" if new_resource.description
  if new_resource.value.nil?
    command << '--ignoreDescriptorItem'
  else
    command << "'--value=#{new_resource.value}'"
  end
  command << new_resource.webapp

  bash "asadmin_set-web-env-entry #{new_resource.webapp} --name #{new_resource.name}" do
    not_if "#{asadmin_command("list-web-env-entry #{new_resource.webapp}")} | grep -F -x -- '#{new_resource.name} (#{new_resource.type}) #{new_resource.value} ignoreDescriptorItem=#{new_resource.value.nil?} //(#{new_resource.description || 'description not specified'})'", :timeout => 150
    timeout 150
    user new_resource.system_user
    group new_resource.system_group
    code asadmin_command(command.join(' '))
  end
end

action :unset do
  command = []
  command << 'unset-web-env-entry'
  command << '--name' << new_resource.name
  command << new_resource.webapp

  bash "asadmin_unset-web-env-entry #{new_resource.name}" do
    only_if "#{asadmin_command("list-web-env-entry #{new_resource.webapp}")} | grep -F -x -- '#{new_resource.name}'", :timeout => 150
    timeout 150
    user new_resource.system_user
    group new_resource.system_group
    code asadmin_command(command.join(' '))
  end
end
