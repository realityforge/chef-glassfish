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

class Chef
  module Asadmin
    def encode_options(options)
      "\"#{options.collect { |v| escape_property(v) }.join(':')}\""
    end

    def encode_parameters(properties)
      "\"#{properties.collect { |k, v| "#{k}=#{escape_property(v)}" }.join(':')}\""
    end

    def asadmin_target_flag
      new_resource.target ? "--target #{new_resource.target}" : ''
    end

    def escape_property(string)
      string.to_s.gsub(/([#{Regexp.escape('\/,=:.!$%^&*|{}[]"`~;')}])/) { |match| "\\#{match}" }
    end

    # asadmin (and REST API) returns JDK version restrictions for JVM options in different format than it requires as input
    # This function converts between the return-format and input-format (or optionally without any version)
    #
    # For example:
    # From: "-Xbootclasspath/p:${com.sun.aas.installRoot}/lib/grizzly-npn-bootstrap-1.6.jar   --> JDK versions: min(1.8.0), max(1.8.0.120) (Inactive on this JDK)"
    # To: "[1.8.0|1.8.0u120]-Xbootclasspath/p:${com.sun.aas.installRoot}/lib/grizzly-npn-bootstrap-1.6.jar"
    #
    def transform_jvm_options(options, withoutversions = false)
      options.map do |line|
        min = ''
        max = ''
        unless withoutversions
          capture = line.match(/min\(([\w\-\d\.]+)\)/)
          min = capture.captures.first unless capture.nil?

          capture = line.match(/max\(([\w\-\d\.]+)\)/)
          max = capture.captures.first unless capture.nil?

          min = min.gsub(/(\d+)\.(\d+)\.(\d+)\.(\d+)/, '\1.\2.\3u\4')
          max = max.gsub(/(\d+)\.(\d+)\.(\d+)\.(\d+)/, '\1.\2.\3u\4')
        end

        base = line.gsub(/   --> JDK versions: [A-Za-z\-\(\d\.\), ]+/, '')

        if min != '' || max != ''
          "[#{min}|#{max}]#{base}"
        else
          base
        end
      end
    end

    def self.pipe_filter(node, pattern, regexp: true, line: false)
      case node['os']
      when 'linux'
        switches = [
          regexp ? '' : '-F',
          line ? '-x' : '',
        ]
        "grep #{switches.join(' ')} -- '#{pattern}'"
      when 'windows'
        switches = [
          regexp ? '/R' : '/L',
          line ? '/X' : '',
        ]
        "findstr #{switches.join(' ')} \"#{pattern}\""
      end
    end

    def pipe_filter(pattern, regexp: true, line: false)
      Asadmin.pipe_filter(node, pattern, regexp: regexp, line: line)
    end

    def asadmin_command(command, remote_command = true, params = {})
      options = {}
      options[:remote_command] = remote_command
      options[:terse] = new_resource.terse
      options[:echo] = new_resource.echo
      options[:username] = new_resource.username
      options[:password_file] = new_resource.password_file
      options[:secure] = new_resource.secure
      options[:admin_port] = new_resource.admin_port
      options.merge!(params)
      Asadmin.asadmin_command(node, command, options)
    end

    def self.generate_component_plan_digest(descriptors)
      require 'digest/md5'

      plan_digest = ::Digest::MD5.new
      content = descriptors.keys.sort.collect do |key|
        digest = ::Digest::MD5.new
        ::File.foreach(descriptors[key]) do |s|
          digest.update(s)
        end
        "#{key}=#{digest.hexdigest}"
      end.join("\n")
      plan_digest.update(content)
      plan_digest.hexdigest
    end

    def self.versioned_component_name(component_name, component_type, version, url, descriptors)
      return component_name if version.nil? && url.nil?

      version_value = version ? version.to_s : Digest::SHA1.hexdigest(url)
      versioned_component_name = "#{component_name}:#{version_value}"
      versioned_component_name = "#{versioned_component_name}+#{generate_component_plan_digest(descriptors)}" if descriptors && !descriptors.empty?
      versioned_component_name = versioned_component_name.tr(':', '_') if component_type.to_s == 'osgi'
      versioned_component_name
    end

    def self.asadmin_command(node, command, options = {})
      args = []
      args << "--terse=#{!!options[:terse]}"
      args << "--echo=#{!!options[:echo]}"
      args << "--user #{options[:username]}" if options[:username]
      args << "--passwordfile=#{options[:password_file]}" if options[:password_file]
      if options[:remote_command].nil? || options[:remote_command]
        args << '--secure' if options[:secure]
        args << "--port #{options[:admin_port]}"
      end

      "#{asadmin_script(node)} #{args.join(' ')} #{command}"
    end

    def self.asadmin_script(node)
      # converting seconds to miliseconds
      ENV['AS_ADMIN_READTIMEOUT'] = (node['glassfish']['asadmin']['timeout'] * 1000).to_s

      script = "#{node['glassfish']['install_dir']}/glassfish/bin/asadmin"
      script.tr!('/', '\\') if node.windows?

      script
    end
  end
end
