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

class Chef
  module Asadmin
    def encode_parameters(properties)
      "'#{properties.collect{|k,v| "#{k}=#{escape_property(v)}"}.join(":")}'"
    end

    def asadmin_target_flag
      new_resource.target ? "--target #{new_resource.target}" : ''
    end

    def escape_property(string)
      string.to_s.gsub(/([#{Regexp.escape('\/,=:.!$%^&*|{}[]"`~;')}])/) {|match| "\\#{match}" }
    end

    def asadmin_command(command, remote_command = true)
      options = {}
      options[:remote_command] = remote_command
      options[:terse] = new_resource.terse
      options[:echo] = new_resource.echo
      options[:username] = new_resource.username
      options[:password_file] = new_resource.password_file
      options[:secure] = new_resource.secure
      options[:admin_port] = new_resource.admin_port
      Asadmin.asadmin_command(node, command, options)
    end

    def self.asadmin_command(node, command, options = {})
      args = []
      args << "--terse" if options[:terse]
      args << "--echo" if options[:echo]
      args << "--user #{options[:username]}" if options[:username]
      args << "--passwordfile=#{options[:password_file]}" if options[:password_file]
      if options[:remote_command].nil? || options[:remote_command]
        args << "--secure" if options[:secure]
        args << "--port #{options[:admin_port]}"
      end

      "#{node['glassfish']['base_dir']}/glassfish/bin/asadmin #{args.join(" ")} #{command}"
    end
  end
end

