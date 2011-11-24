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
    def asadmin_command(command, options = {})
      args = []
      args << "--terse=#{!!options[:terse]}"
      args << "--echo=#{!!options[:echo]}"
      args << "--interactive=false"
      # TODO: Handle domain_name and lookup credentials/etc to access
      #[--host host]
      #[--port port]
      #[--user admin-user]
      #[--passwordfile filename]
      #[--secure={false|true}]
      "#{node[:glassfish][:base_dir]}/glassfish/bin/asadmin #{args.join(" ")} #{command}"
    end

    def asadmin_jvm_option(jvm_option, options = {})
      # There is a need to escape : with a \
      asadmin_command("create-jvm-options -- '#{jvm_option.gsub(':', '\:')}'", options)
    end

    def asadmin_set(parameter, options = {})
      asadmin_command("set #{parameter}", options)
    end
  end
end

