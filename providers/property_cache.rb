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

require 'English'

include Chef::Asadmin

action :create do
  command = shell_out(asadmin_command('get "*"', true, terse: true, echo: false))
  output = command.stdout

  raise 'Error caching properties' unless command.exitstatus.to_i == 0

  separator = if node.windows?
                "\r\n"
              else
                "\n"
              end

  values = {}
  output.split(separator).each do |line|
    index = line.index('=')
    key = line[0, index]
    value = line[index + 1, line.size]
    values[key] = value
  end
  RealityForge::GlassFish.set_property_cache(node, new_resource.domain_name, values)
end

action :delete do
  RealityForge::GlassFish.set_property_cache(node, new_resource.domain_name, nil)
end
