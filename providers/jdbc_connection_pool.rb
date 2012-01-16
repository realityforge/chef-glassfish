#
# Cookbook Name:: glassfish
# Recipe:: default
#
# Copyright 2011, Peter Donald
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
  bash "asadmin_create_jdbc_connection_pool #{new_resource.name}" do
    not_if "#{asadmin_command('list-jdbc-connection-pools')} | grep -x -- '#{new_resource.name}'"
    user node[:glassfish][:user]
    group node[:glassfish][:group]
    code asadmin_command("create-jdbc-connection-pool #{new_resource.parameters.join(' ')} #{new_resource.name}")
  end
end
