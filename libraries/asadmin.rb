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

    def escape_property(string)
      string.gsub('\\', '\\\\').gsub(':', '\\:').gsub('""', '\\""')
    end

    def asadmin_command(command, remote_command = true)
      args = []
      args << "--terse" if new_resource.terse
      args << "--echo" if new_resource.echo
      args << "--user #{new_resource.username}" if new_resource.username
      args << "--passwordfile=#{new_resource.password_file}" if new_resource.password_file
      if remote_command
        args << "--secure" if new_resource.secure
        args << "--port #{new_resource.admin_port}"
      end

      "#{node['glassfish']['base_dir']}/glassfish/bin/asadmin #{args.join(" ")} #{command}"
    end

    def asadmin_jvm_option(jvm_option)
      # There is a need to escape : with a \
      asadmin_command("create-jvm-options -- '#{jvm_option.gsub(':', '\:')}'")
    end

    def asadmin_set_web_env_entry(webapp, key, value, type)
      value_string = value.nil? ? "--ignoreDescriptorItem" : "--value=#{value} --type #{type}"
      asadmin_command("set-web-env-entry --name=#{key} #{value_string} #{webapp}")
    end

    def asadmin_create_custom_resource(key, value, type, factory_class = "org.glassfish.resources.custom.factory.PrimitivesAndStringFactory")
      asadmin_command("create-custom-resource --factoryclass #{factory_class} --restype #{type} --property \"value=#{value.gsub(':','\:')}\" #{key}")
    end
  end
end

