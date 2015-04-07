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

action :set do
  cache_present = RealityForge::GlassFish.is_property_cache_present?(node, new_resource.domain_name)
  may_need_update =
    cache_present ?
      new_resource.value != RealityForge::GlassFish.get_cached_property(node, new_resource.domain_name, new_resource.key) :
      true

  if may_need_update
    bash "asadmin_set #{new_resource.key}=#{new_resource.value}" do
      unless cache_present
        not_if "#{asadmin_command("get #{new_resource.key}")} | grep -F -x -- '#{new_resource.key}=#{new_resource.value}'", :timeout => 150
      end
      timeout 150
      user new_resource.system_user
      group new_resource.system_group
      code asadmin_command("set '#{new_resource.key}=#{new_resource.value}'")
    end

    if cache_present
      RealityForge::GlassFish.set_cached_property(node, new_resource.domain_name, new_resource.key, new_resource.value)
    end
  end
end
