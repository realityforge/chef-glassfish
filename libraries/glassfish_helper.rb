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

class RealityForge
  module GlassFish
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

      def any_cached_property_start_with?(node, domain_key, property_key)
        regex = /^#{Regexp.escape(property_key)}/
        get_property_cache(node, domain_key).keys.any? { |k| k =~ regex }
      end

      def property_cache_present?(node, domain_key)
        !!node.run_state["glassfish_properties_#{domain_key}"]
      end

      def get_property_cache(node, domain_key)
        values = node.run_state["glassfish_properties_#{domain_key}"]
        raise 'No properties cached' unless values
        values
      end

      def set_property_cache(node, domain_key, values)
        node.run_state["glassfish_properties_#{domain_key}"] = values
      end

      def set_cached_property(node, domain_key, key, value)
        get_property_cache(node, domain_key)[key] = value
      end

      def get_cached_property(node, domain_key, key)
        get_property_cache(node, domain_key)[key] || ''
      end

      def url_responding_with_code?(url, username, password, code)
        uri = URI(url)
        res = nil
        http = Net::HTTP.new(uri.hostname, uri.port)
        if url =~ /https\:/
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end
        http.start do |http| # rubocop:disable Lint/ShadowingOuterLocalVariable
          request = Net::HTTP::Get.new(uri.request_uri)
          request.basic_auth username, password
          request['Accept'] = 'application/json'
          res = http.request(request)
        end
        if res.code.to_s == code.to_s
          Chef::Log.debug "GlassFish response OK - #{res.code} to #{url}"
          return true
        end
        Chef::Log.debug "GlassFish not responding OK - #{res.code} to #{url}"
      rescue StandardError => e # Fallback to secure/insecure
        Chef::Log.info "GlassFish error while accessing web interface at #{url}"
        Chef::Log.info e.message
        Chef::Log.debug e.backtrace.join("\n")
        false
      end

      def block_until_glassfish_up(username, password, ipaddress, admin_port)
        require 'net/https'

        fail_count = 0

        # Looks like we need to check both http/https because secure_admin might or might not be enabled

        http_base_url = "http://#{ipaddress}:#{admin_port}"
        https_base_url = "https://#{ipaddress}:#{admin_port}"
        http_nodes_url = "#{http_base_url}/management/domain/nodes"
        https_nodes_url = "#{https_base_url}/management/domain/nodes"
        http_applications_url = "#{http_base_url}/management/domain/applications"
        https_applications_url = "#{https_base_url}/management/domain/applications"

        loop do
          raise 'GlassFish failed to become operational' if fail_count > 50
          password = password
          if (url_responding_with_code?(http_nodes_url, username, password, 200) || url_responding_with_code?(https_nodes_url, username, password, 200)) &&
             (url_responding_with_code?(http_applications_url, username, password, 200) || url_responding_with_code?(https_applications_url, username, password, 200)) &&
             (url_responding_with_code?(http_base_url, username, password, 200) || url_responding_with_code?(https_base_url, username, password, 200))
            break
          end
          fail_count += 1
          sleep 3
        end
      end
    end
  end
end
