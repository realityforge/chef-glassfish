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

class Chef
  module Asadmin
    def asadmin_command(command, remote_command = true)
      args = []
      args << "--terse" if new_resource.terse
      args << "--echo" if new_resource.echo
      if remote_command
        username = node[:glassfish][:domain_definitions][new_resource.domain_name][:config][:username]
        args << "--user #{username}" if username
        if node[:glassfish][:domain_definitions][new_resource.domain_name][:config][:password]
          args << "--passwordfile #{node[:glassfish][:domains_dir]}/#{new_resource.domain_name}/admin_passwd"
        end
        if node[:glassfish][:domain_definitions][new_resource.domain_name][:config][:secure]
          args << "--secure"
        end
        admin_port = node[:glassfish][:domain_definitions][new_resource.domain_name][:config][:admin_port]
        args << "--port #{admin_port}"
      end

      "#{node[:glassfish][:base_dir]}/glassfish/bin/asadmin #{args.join(" ")} #{command}"
    end

    def asadmin_jvm_option(jvm_option)
      # There is a need to escape : with a \
      asadmin_command("create-jvm-options -- '#{jvm_option.gsub(':', '\:')}'")
    end

    def asadmin_set(parameter)
      asadmin_command("set #{parameter}")
    end
  end
end

