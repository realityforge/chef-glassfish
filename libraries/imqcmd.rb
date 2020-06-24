#
# Copyright:: Peter Donald
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
  module Imqcmd
    def imqcmd_command(command, params = {})
      options = {}
      options[:host] = new_resource.host
      options[:port] = new_resource.port
      options[:username] = new_resource.username
      options[:passfile] = new_resource.passfile
      options.merge!(params)
      Imqcmd.imqcmd_command(node, command, options)
    end

    def self.imqcmd_command(node, command, options = {})
      args = []
      args << '-f'
      args << "-javahome #{node['java']['java_home']}"
      args << "-b #{options[:host]}:#{options[:port]}"
      args << "-u #{options[:username]}"
      args << "-passfile #{options[:passfile]}"

      "#{imqcmd_script(node)} #{args.join(' ')} #{command}"
    end

    def self.imqcmd_script(node)
      "#{node['glassfish']['install_dir']}/mq/bin/imqcmd"
    end
  end
end
