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

include Chef::Asadmin

use_inline_resources

action :run do
  bash "asadmin #{new_resource.command}" do
    timeout 150
    user new_resource.system_user
    group new_resource.system_group
    ignore_failure new_resource.ignore_failure
    returns new_resource.returns
    code asadmin_command(new_resource.command)
  end
end
