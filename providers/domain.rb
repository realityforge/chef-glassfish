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

def asadmin_command(command)
  "#{node[:glassfish][:base_dir]}/glassfish/bin/asadmin #{command}"
end

def asadmin_jvm_option(jvm_option)
  asadmin_command("create-jvm-options -- #{jvm_option}")
end

def asadmin_set(parameter)
  asadmin_command("set #{parameter}")
end

action :create do
  bash "create domain" do
    not_if "#{asadmin_command('list-domains')} | grep '#{new_resource.domain_name} '"

    command_string = []

    command_string << asadmin_command("create-domain --nopassword #{new_resource.domain_name}")
    command_string << asadmin_command("verify-domain-xml #{new_resource.domain_name}")
    command_string << asadmin_command("start-domain #{new_resource.domain_name}")

    if false
      new_resource.jvm_options.each do |jvm_option|
        command_string << asadmin_jvm_option(jvm_option)
      end

      command_string << asadmin_jvm_option("-XX:MaxPermSize=#{new_resource.max_perm_size}m")
      command_string << asadmin_jvm_option("-Xss#{new_resource.max_stack_size}k")
      command_string << asadmin_jvm_option("-Xmx#{new_resource.max_memory}m")

      if new_resource.tune_gc
        command_string << asadmin_jvm_option("-XX:+AggressiveHeap")
        command_string << asadmin_jvm_option("-XX:+DisableExplicitGC")
        command_string << asadmin_jvm_option("-XX:+UseCompressedOops")
        command_string << asadmin_jvm_option("-XX:+UseParallelOldGC")
        command_string << asadmin_jvm_option("-XX:ParallelGCThreads=#{node[:cpu].size}")
      end
    end

    user node[:glassfish][:user]
    group node[:glassfish][:group]
    code command_string.join("\n")
  end

  template "/etc/init.d/glassfish-#{new_resource.domain_name}" do
    source "glassfish-init.d-script.erb"
    mode "0755"
    cookbook 'glassfish'
    variables(:domain_name => new_resource.domain_name)
  end

  service "glassfish-#{new_resource.domain_name}" do
    supports :start => true, :restart => true, :stop => true
    action [:enable, :start]
  end
end

action :destroy do
  execute "destroy domain" do
    only_if "#{asadmin_command('list-domains')} | grep '#{new_resource.domain_name} '"
    command_string = []

    command_string << "#{asadmin_command("stop-domain #{new_resource.domain_name}")} 2> /dev/null > /dev/null"
    command_string << asadmin_command("delete-domain #{new_resource.domain_name}")

    command command_string.join("\n")
  end
end
