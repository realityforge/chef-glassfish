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

include Chef::Asadmin

action :set do
  cache_present = RealityForge::GlassFish.property_cache_present?(node, new_resource.domain_name)
  may_need_update = if cache_present
                      new_resource.value != RealityForge::GlassFish.get_cached_property(node, new_resource.domain_name, new_resource.key)
                    else
                      true
                    end

  if may_need_update
    execute "asadmin_set #{new_resource.key}=#{new_resource.value}" do
      unless cache_present
        filter = pipe_filter("#{new_resource.key}=#{new_resource.value}", regexp: false, line: false)
        not_if "#{asadmin_command("get #{new_resource.key}")} | #{filter}", timeout: node['glassfish']['asadmin']['timeout'] + 5
      end
      # execute should wait for asadmin to time out first, if it doesn't because of some problem, execute should time out eventually
      timeout node['glassfish']['asadmin']['timeout'] + 5

      user new_resource.system_user unless node.windows?
      group new_resource.system_group unless node.windows?

      command asadmin_command("set \"#{new_resource.key}=#{new_resource.value}\"")
    end

    RealityForge::GlassFish.set_cached_property(node, new_resource.domain_name, new_resource.key, new_resource.value) if cache_present
  end
end
