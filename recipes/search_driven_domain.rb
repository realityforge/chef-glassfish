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

# Configures 0 or more GlassFish domains using search to generate the configuration.

node['glassfish']['domains'].each_pair do |domain_key, definition|
  next unless definition['discover']
  domain_key = domain_key.to_s
  databag_key = definition['discover']['type'] || domain_key
  query = definition['discover']['query'] || '*:*'
  sort_key = definition['discover']['sort']
  entry_key = definition['discover']['entry_key'] || 'config'

  ::Chef::Log.info "Collecting data for GlassFish Domain #{domain_key} from indexes #{databag_key}"
  ::Chef::SearchBlender.blend_search_results_into_node(node,
                                                        databag_key,
                                                        query,
                                                        entry_key,
                                                        "glassfish.domains.#{domain_key}",
                                                        'sort' => sort_key)
end

include_recipe 'glassfish::attribute_driven_domain'
