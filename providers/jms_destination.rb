#
# Copyright James Walker
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
  command << 'create-jmsdest'
  command << '--desttype' << new_resource.desttype
  command << new_resource.name

  bash "asadmin_create-jmsdest #{new_resource.name}" do
    not_if "#{asadmin_command('list-jmsdest')} | grep -F -x -- '#{new_resource.name}'", :timeout => node['glassfish']['asadmin']['timeout']
    timeout node['glassfish']['asadmin']['timeout']
    user new_resource.system_user
    group new_resource.system_group
    code asadmin_command(command.join(' '))
  end
end

action :delete do
  command = []
  command << 'delete-jmsdest'
  command << asadmin_target_flag
  command << new_resource.name

  bash "asadmin_delete-jmsdest #{new_resource.name}" do
    only_if "#{asadmin_command('list-jmsdest')} | grep -F -x -- '#{new_resource.name}'", :timeout => node['glassfish']['asadmin']['timeout']
    timeout node['glassfish']['asadmin']['timeout']
    user new_resource.system_user
    group new_resource.system_group
    code asadmin_command(command.join(' '))
  end
end
