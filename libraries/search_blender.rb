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

class ::Chef
  module SearchBlender
    class << self
      def blend_search_results_into_node(node, search_key, query, input_path, output_path, options = {})
        sort_key = options['sort'] || 'X_CHEF_id_CHEF_X asc'

        ::Chef::Search::Query.new.search(search_key, query, sort_key) do |config|
          value = input_path.split('.').inject(config) { |element, key| element.nil? ? nil : element[key] }
          if value
            existing = output_path.split('.').inject(node) { |element, key| element[key] }
            if existing
              results = ::Chef::Mixin::DeepMerge.deep_merge(value, existing.to_hash, {:preserve_unmergeables => false}).to_hash
            else
              results = value.dup
            end
            output_keys = output_path.split('.')
            output_entry = output_keys[0...-1].inject(node.override) { |element, key| element[key] }
            output_entry[output_keys.last] = results
          end
        end
      end
    end
  end
end
