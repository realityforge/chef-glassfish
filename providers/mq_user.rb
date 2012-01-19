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

def imqusermgr_command(command)
  "#{node[:glassfish][:base_dir]}/mq/bin/imqusermgr #{command} -i '#{new_resource.instance}' -varhome '#{new_resource.var_home}'"
end

action :add do
  bash "mq_user #{new_resource.user}" do
    not_if "#{imqusermgr_command("list")} | grep -- '#{new_resource.user} '"
    user node[:glassfish][:user]
    group node[:glassfish][:group]
    code imqusermgr_command("add -u '#{new_resource.user}' -p '#{new_resource.password}' -g '#{new_resource.group}'")
  end
end

action :remove do
  bash "mq_user #{new_resource.user}" do
    only_if "#{imqusermgr_command("list")} | grep -- '#{new_resource.user} '"
    user node[:glassfish][:user]
    group node[:glassfish][:group]
    code imqusermgr_command("delete -u '#{new_resource.user}' -f")
  end
end
