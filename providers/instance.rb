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
  args << 'create-instance'
  args << "--node #{new_resource.node_name}"
  args << "--lbenabled=#{new_resource.lbenabled}" if new_resource.lbenabled
  args << "--portbase=#{new_resource.portbase}" if new_resource.portbase
  args << "--checkports=#{new_resource.checkports}" if new_resource.checkports
  args << '--systemproperties' << encode_parameters(new_resource.systemproperties) unless new_resource.systemproperties.empty?
  args << new_resource.instance_name

  execute "create instance #{new_resource.instance_name}" do
    # execute should wait for asadmin to time out first, if it doesn't because of some problem, execute should time out eventually
    timeout node['glassfish']['asadmin']['timeout'] + 5
    user new_resource.system_user unless node.windows?
    group new_resource.system_group unless node.windows?
    command asadmin_command(args.join(' '))

    filter = pipe_filter(new_resource.instance_name, regexp: false, line: true)
    not_if "#{asadmin_command('list-instances')} #{new_resource.instance_name} | #{filter}", timeout: node['glassfish']['asadmin']['timeout'] + 5
  end
end

action :delete do
  args = []
  args << 'delete-instance'
  args << new_resource.instance_name

  execute "delete instance #{new_resource.instance_name}" do
    # execute should wait for asadmin to time out first, if it doesn't because of some problem, execute should time out eventually
    timeout node['glassfish']['asadmin']['timeout'] + 5
    user new_resource.system_user unless node.windows?
    group new_resource.system_group unless node.windows?
    command asadmin_command(args.join(' '))

    filter = pipe_filter(new_resource.instance_name, regexp: false, line: true)
    only_if "#{asadmin_command('list-instances')} #{new_resource.instance_name} | #{filter}", timeout: node['glassfish']['asadmin']['timeout'] + 5
  end
end

action :start do
  args = []
  args << 'start-local-instance'
  args << new_resource.instance_name

  execute "stop instance #{new_resource.instance_name}" do
    # execute should wait for asadmin to time out first, if it doesn't because of some problem, execute should time out eventually
    timeout node['glassfish']['asadmin']['timeout'] + 5

    user new_resource.system_user unless node.windows?
    group new_resource.system_group unless node.windows?
    command asadmin_command(args.join(' '))

    filter = pipe_filter("#{new_resource.instance_name}.*running", regexp: true)
    not_if "#{asadmin_command('list-instances')} #{new_resource.instance_name} | #{filter}", timeout: node['glassfish']['asadmin']['timeout'] + 5
  end
end

action :stop do
  args = []
  args << 'stop-local-instance'
  args << new_resource.instance_name

  execute "delete instance #{new_resource.instance_name}" do
    # execute should wait for asadmin to time out first, if it doesn't because of some problem, execute should time out eventually
    timeout node['glassfish']['asadmin']['timeout'] + 5

    user new_resource.system_user unless node.windows?
    group new_resource.system_group unless node.windows?
    command asadmin_command(args.join(' '))

    filter = pipe_filter("^#{new_resource.instance_name}.*running", regexp: true)
    only_if "#{asadmin_command('list-instances')} #{new_resource.instance_name} | #{filter}", timeout: node['glassfish']['asadmin']['timeout'] + 5
  end
end
