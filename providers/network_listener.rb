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
  command << 'create-network-listener'
  command << asadmin_target_flag
  if new_resource.address
    command << '--address' << new_resource.address
  end
  command << '--listenerport ' << new_resource.listenerport
  command << '--threadpool ' << new_resource.threadpool
  command << '--protocol ' << new_resource.protocol
  command << '--transport ' << new_resource.transport
  command << "--enabled=#{new_resource.enabled}"
  command << "--jkenabled=#{new_resource.jkenabled}"

  command << new_resource.listener_name

  bash "asadmin_create-network-listener #{new_resource.listener_name}" do
    not_if "#{asadmin_command('list-network-listeners')} #{new_resource.target} | grep -F -x -- '#{new_resource.listener_name}'", :timeout => node['glassfish']['asadmin']['timeout']
    timeout node['glassfish']['asadmin']['timeout'] + 5
    user new_resource.system_user
    group new_resource.system_group
    code asadmin_command(command.join(' '))
  end
end

action :delete do
  command = []
  command << 'delete-network-listener'
  command << asadmin_target_flag
  command << new_resource.listener_name

  bash "asadmin_delete_network-listener #{new_resource.listener_name}" do
    only_if "#{asadmin_command('list-network-listeners')} #{new_resource.target} | grep -F -x -- '#{new_resource.listener_name}'", :timeout => node['glassfish']['asadmin']['timeout']
    timeout node['glassfish']['asadmin']['timeout'] + 5
    user new_resource.system_user
    group new_resource.system_group
    code asadmin_command(command.join(' '))
  end
end
