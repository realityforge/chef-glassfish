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

# <> @attribute secure If true use SSL when communicating with the domain for administration.
property :secure, [TrueClass, FalseClass], default: false

# <> @attribute username The username to use when communicating with the domain.
property :username, String, default: 'admin'

# <> @attribute password The password must be stored assigned to appropriate key.
property :password, String, default: nil

# <> @attribute admin_port The port on which the web management console is bound.
property :admin_port, Integer, default: 4848

default_action :run

action :run do
  RealityForge::GlassFish.block_until_glassfish_up(new_resource.secure, new_resource.username, new_resource.password, new_resource.admin_port)
end
