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

# <> @attribute username The username to use when communicating with the domain.
property :username, String, default: 'admin'

# <> @attribute password_file The file in which the password must be stored assigned to appropriate key.
property :password_file, String, required: true

# <> @attribute ipaddress The IP address to connect to glassfish.
property :ipaddress, String, default: lazy { node['ipaddress'] }

# <> @attribute admin_port The port on which the web management console is bound.
property :admin_port, Integer, default: 4848

action :run do
  password = nil
  ::File.foreach(new_resource.password_file) do |line|
    (var = line.match(/AS_ADMIN_PASSWORD=(.*)/)&.captures&.first&.strip)
    password = var if var
  end
  raise 'Unable to get password' if password.nil?
  RealityForge::GlassFish.block_until_glassfish_up(new_resource.username, password, new_resource.ipaddress, new_resource.admin_port)
end
