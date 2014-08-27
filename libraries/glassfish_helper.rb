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

class RealityForge #nodoc
  module GlassFish #nodoc
    class << self
      # Return the current glassfish domain name
      #
      # The domain is typically set when configuration run starts
      #
      def get_current_domain(node)
        domain_key = node.run_state['glassfish_domain']
        raise 'No domain specified' unless domain_key
        domain_key
      end

      # Set the current glassfish domain name
      #
      def set_current_domain(node, domain_key)
        node.run_state['glassfish_domain'] = domain_key
      end

      # Return the current broker instance.
      #
      # The instance is typically set when configuration run starts
      #
      def get_current_broker_instance(node)
        broker_instance = node.run_state['broker_instance']
        raise 'No broker instance specified' unless broker_instance
        broker_instance
      end

      # Set the current broker instance.
      #
      def set_current_broker_instance(node, broker_instance)
        node.run_state['broker_instance'] = broker_instance
      end
    end
  end
end
