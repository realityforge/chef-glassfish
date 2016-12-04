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
  instance_exists = 0 != `#{asadmin_command('list-instances')} #{new_resource.instance_name} | grep -- '#{new_resource.instance_name} '`.strip.split("\n").size

  unless instance_exists
    Chef::Log.info "Creating instance #{new_resource.instance_name} in #{new_resource.domain_name}"

    execute "create instance #{new_resource.instance_name}" do
      args = []
      args << 'create-instance'
      args << "--node #{new_resource.node_name}"
      args << "--lbenabled=#{new_resource.lbenabled}" if new_resource.lbenabled
      args << "--portbase=#{new_resource.portbase}" if new_resource.portbase
      args << "--checkports=#{new_resource.checkports}" if new_resource.checkports
      args << '--systemproperties' << encode_parameters(new_resource.systemproperties) unless new_resource.systemproperties.empty?
      args << new_resource.instance_name
      # execute should wait for asadmin to time out first, if it doesn't because of some problem, execute should time out eventually
      timeout node['glassfish']['asadmin']['timeout'] + 5 + 5
      user new_resource.system_user unless node['os'] == 'windows'
      group new_resource.system_group unless node['os'] == 'windows'
      command asadmin_command(args.join(' '))
    end
  end
end

action :delete do
  instance_exists = 0 != `#{asadmin_command('list-instances')} #{new_resource.instance_name} | grep -- '#{new_resource.instance_name} '`.strip.split("\n").size

  if instance_exists
    Chef::Log.info "Deleting instance #{new_resource.instance_name} in #{new_resource.domain_name}"

    execute "delete instance #{new_resource.instance_name}" do
      args = []
      args << 'delete-instance'
      args << new_resource.instance_name
      # execute should wait for asadmin to time out first, if it doesn't because of some problem, execute should time out eventually
      timeout node['glassfish']['asadmin']['timeout'] + 5 + 5
      user new_resource.system_user unless node['os'] == 'windows'
      group new_resource.system_group unless node['os'] == 'windows'
      command asadmin_command(args.join(' '))
    end
  end
end

action :start do
  instance_running = 1 == `#{asadmin_command('list-instances')} #{new_resource.instance_name} | grep -E '^#{new_resource.instance_name}\\s*running'`.strip.split("\n").size

  unless instance_running
    Chef::Log.info "Starting instance #{new_resource.instance_name} in #{new_resource.domain_name}"

    execute "stop instance #{new_resource.instance_name}" do
      args = []
      args << 'start-local-instance'
      args << new_resource.instance_name
      # execute should wait for asadmin to time out first, if it doesn't because of some problem, execute should time out eventually
      timeout node['glassfish']['asadmin']['timeout'] + 5 + 5
      user new_resource.system_user unless node['os'] == 'windows'
      group new_resource.system_group unless node['os'] == 'windows'
      command asadmin_command(args.join(' '))
    end
  end
end

action :stop do
  instance_running = 1 == `#{asadmin_command('list-instances')} #{new_resource.instance_name} | grep -E '^#{new_resource.instance_name}\\s*running'`.strip.split("\n").size

  if instance_running
    Chef::Log.info "Stopping instance #{new_resource.instance_name} in #{new_resource.domain_name}"

    execute "delete instance #{new_resource.instance_name}" do
      args = []
      args << 'stop-local-instance'
      args << new_resource.instance_name
      # execute should wait for asadmin to time out first, if it doesn't because of some problem, execute should time out eventually
      timeout node['glassfish']['asadmin']['timeout'] + 5 + 5
      user new_resource.system_user unless node['os'] == 'windows'
      group new_resource.system_group unless node['os'] == 'windows'
      command asadmin_command(args.join(' '))
    end
  end
end
