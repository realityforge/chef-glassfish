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

  parameters = [:connectiondefinition, :raname, :transactionsupport] +
    ::Chef::Resource::GlassfishConnectorConnectionPool::NUMERIC_ATTRIBUTES +
    ::Chef::Resource::GlassfishConnectorConnectionPool::BOOLEAN_ATTRIBUTES

  args = []
  args << 'create-connector-connection-pool'
  parameters.each do |key|
    args << "--#{key}=#{new_resource.send(key)}" if new_resource.send(key)
  end

  args << '--property' << encode_parameters(new_resource.properties) unless new_resource.properties.empty?
  args << "--description='#{new_resource.description}'" if new_resource.description
  args << new_resource.pool_name


  execute "asadmin_create-connector-connection-pool #{new_resource.pool_name}" do
    not_if "#{asadmin_command('list-connector-connection-pools')} | grep -F -x -- '#{new_resource.pool_name}'", :timeout => node['glassfish']['asadmin']['timeout'] + 5
    timeout node['glassfish']['asadmin']['timeout'] + 5
    user new_resource.system_user unless node['os'] == 'windows'
    group new_resource.system_group unless node['os'] == 'windows'
    command asadmin_command(args.join(' '))
  end
end

action :delete do
  args = []
  args << 'delete-connector-connection-pool'
  args << '--cascade=true'
  args << new_resource.pool_name

  execute "asadmin_delete-connector-connection-pool #{new_resource.pool_name}" do
    only_if "#{asadmin_command('list-connector-connection-pools')} | grep -F -x -- '#{new_resource.pool_name}'", :timeout => node['glassfish']['asadmin']['timeout'] + 5
    timeout node['glassfish']['asadmin']['timeout'] + 5
    user new_resource.system_user unless node['os'] == 'windows'
    group new_resource.system_group unless node['os'] == 'windows'
    command asadmin_command(args.join(' '))
  end
end
