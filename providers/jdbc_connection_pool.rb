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

  parameters = [:restype, :isolationlevel, :validationmethod] +
    ::Chef::Resource::GlassfishJdbcConnectionPool::STRING_ATTRIBUTES +
    ::Chef::Resource::GlassfishJdbcConnectionPool::NUMERIC_ATTRIBUTES +
    ::Chef::Resource::GlassfishJdbcConnectionPool::BOOLEAN_ATTRIBUTES

  command = []
  command << "create-jdbc-connection-pool"
  parameters.each do |key|
    command << "--#{key}=#{new_resource.send(key)}" if new_resource.send(key)
  end

  command << "--property" << encode_parameters(new_resource.properties) unless new_resource.properties.empty?
  command << "--description" << "'#{new_resource.description}'" if new_resource.description
  command << new_resource.name


  bash "asadmin_create_jdbc_connection_pool #{new_resource.name}" do
    not_if "#{asadmin_command('list-jdbc-connection-pools')} | grep -x -- '#{new_resource.name}'"
    user node['glassfish']['user']
    group node['glassfish']['group']
    code asadmin_command(command.join(' '))
  end
end

action :delete do
  command = []
  command << "delete-jdbc-connection-pool"
  command << "--cascade=true"
  command << new_resource.name

  bash "asadmin_delete_jdbc_connection_pool #{new_resource.name}" do
    only_if "#{asadmin_command('list-jdbc-connection-pools')} | grep -x -- '#{new_resource.name}'"
    user node['glassfish']['user']
    group node['glassfish']['group']
    code asadmin_command(command.join(' '))
  end
end
