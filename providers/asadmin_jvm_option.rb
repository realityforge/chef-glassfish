#
# Cookbook Name:: glassfish
# Recipe:: default
#
# Copyright 2011, Fire Information Systems Group
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

action :run do
  bash "asadmin_jvm_option #{new_resource.jvm_option}" do
    not_if "#{asadmin_command('list-jvm-options')} | grep -- '#{new_resource.jvm_option}'"
    user node[:glassfish][:user]
    group node[:glassfish][:group]
    code asadmin_jvm_option(new_resource.jvm_option)
    notifies :restart, resources(:service => "glassfish-#{new_resource.domain_name}")
  end
end
