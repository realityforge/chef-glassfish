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
          logger.debug "GlassFish response OK - #{res.code} to #{url}"
          return true
        end
        logger.debug "GlassFish not responding OK - #{res.code} to #{url}"
      rescue StandardError => e
        logger.debug "GlassFish error while accessing web interface at #{url}"
        logger.debug e.message
        logger.debug e.backtrace.join("\n")
        url
      end

      def block_until_glassfish_up(remote_access, username, password, ipaddress, admin_port)
        require 'net/https' if remote_access

        fail_count = 0
        loop do
          raise 'GlassFish failed to become operational' if fail_count > 50
          base_url = "http#{remote_access ? 's' : ''}://#{ipaddress}:#{admin_port}"
          nodes_url = "#{base_url}/management/domain/nodes"
          applications_url = "#{base_url}/management/domain/applications"
          password = password
          if url_responding_with_code?(nodes_url, username, password, 200) &&
             url_responding_with_code?(applications_url, username, password, 200) &&
             url_responding_with_code?(base_url, username, password, 200)
            sleep 1
            break
          end
          fail_count += 1
          sleep 1
        end
      end
    end
  end
end
