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
  command << 'create-transport'
  command << asadmin_target_flag
  if new_resource.selectionkeyhandler
    command << '--selectionkeyhandler' << new_resource.selectionkeyhandler
  end
  command << '--acceptorthreads' << new_resource.acceptorthreads
  command << '--buffersizebytes' << new_resource.buffersizebytes
  command << '--bytebuffertype' << new_resource.bytebuffertype
  command << '--classname' << new_resource.classname
  command << "--displayconfiguration=#{new_resource.displayconfiguration}"
  command << "--enablesnoop=#{new_resource.enablesnoop}"
  command << '--idlekeytimeoutseconds' << new_resource.idlekeytimeoutseconds
  command << '--maxconnectionscount' << new_resource.maxconnectionscount
  command << '--readtimeoutmillis' << new_resource.readtimeoutmillis
  command << '--writetimeoutmillis' << new_resource.writetimeoutmillis
  command << '--selectorpolltimeoutmillis' << new_resource.selectorpolltimeoutmillis
  command << "--tcpnodelay=#{new_resource.tcpnodelay}"

  command << new_resource.transport_name

  bash "asadmin_create-transport #{new_resource.transport_name}" do
    not_if "#{asadmin_command('list-transports')} #{new_resource.target} | grep -F -x -- '#{new_resource.transport_name}'", :timeout => node['glassfish']['asadmin']['timeout']
    timeout node['glassfish']['asadmin']['timeout'] + 5
    user new_resource.system_user
    group new_resource.system_group
    code asadmin_command(command.join(' '))
  end
end

action :delete do
  command = []
  command << 'delete-transport'
  command << asadmin_target_flag
  command << new_resource.transport_name

  bash "asadmin_delete_transport #{new_resource.transport_name}" do
    only_if "#{asadmin_command('list-transports')} #{new_resource.target} | grep -F -x -- '#{new_resource.transport_name}'", :timeout => node['glassfish']['asadmin']['timeout']
    timeout node['glassfish']['asadmin']['timeout'] + 5
    user new_resource.system_user
    group new_resource.system_group
    code asadmin_command(command.join(' '))
  end
end
