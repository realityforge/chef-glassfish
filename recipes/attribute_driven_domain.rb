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

=begin
#<
Configures 0 or more GlassFish domains using the glassfish/domains attribute.

The `attribute_driven_domain` recipe interprets attributes on the node and defines the resources described in the attributes.
#>
=end

include_recipe 'glassfish::default'

def gf_scan_existing_resources(admin_port, username, password_file, secure, command)
  options = {:remote_command => true, :terse => true, :echo => false}
  options[:username] = username if username
  options[:password_file] = password_file if password_file
  options[:secure] = secure if secure
  options[:admin_port] = admin_port if admin_port

  Chef::Log.debug "Issuing #{Asadmin.asadmin_command(node, command, options)}"
  output = `#{Asadmin.asadmin_command(node, command, options)} 2> /dev/null`
  return if output =~ /^Nothing to list.*/ || output =~ /^No such local command.*/ || output =~ /^Command .* failed\./
  lines = output.split("\n")

  lines.each do |line|
    if line =~ /CLI[0-9]+: Warning.*/
      Chef::Log.warn "Ignoring asadmin output: #{line}"
    else
      existing = line.scan(/^(\S+)/).flatten[0]
      yield existing
    end
  end
end

def gf_priority(value)
  value.is_a?(Hash) && value['priority'] ? value['priority'] : 100
end

def gf_sort(hash)
  Hash[hash.sort_by {|key, value| "#{"%04d" % gf_priority(value)}#{key}"}]
end

gf_sort(node['glassfish']['domains']).each_pair do |domain_key, definition|
  if definition['recipes'] && definition['recipes']['before']
    gf_sort(definition['recipes']['before']).each_pair do |recipe, config|
      Chef::Log.info "Including domain 'before' recipe '#{recipe}' Priority: #{gf_priority(config)}"
      include_recipe recipe
    end
  end
end

gf_sort(node['glassfish']['domains']).each_pair do |domain_key, definition|
  domain_key = domain_key.to_s

  Chef::Log.info "Defining GlassFish Domain #{domain_key}"

  admin_port = definition['config']['admin_port']
  username = definition['config']['username']
  secure = definition['config']['secure']
  password_file = username ? "#{node['glassfish']['domains_dir']}/#{domain_key}_admin_passwd" : nil
  system_username = definition['config']['system_user']
  system_group = definition['config']['system_group']

  if (definition['config']['port'] && definition['config']['port'] < 1024) || (admin_port && admin_port < 1024)
    include_recipe 'authbind'
  end

  if 'runit' == definition['config']['init_style']
    include_recipe 'runit::default'
  end

  Chef::Log.info "Defining GlassFish Domain #{domain_key} - domain"

  glassfish_domain domain_key do
    min_memory definition['config']['min_memory'] if definition['config']['min_memory']
    max_memory definition['config']['max_memory'] if definition['config']['max_memory']
    max_perm_size definition['config']['max_perm_size'] if definition['config']['max_perm_size']
    max_stack_size definition['config']['max_stack_size'] if definition['config']['max_stack_size']
    port definition['config']['port'] if definition['config']['port']
    admin_port admin_port if admin_port
    username username if username
    password_file password_file if password_file
    secure secure if secure
    password definition['config']['password'] if definition['config']['password']
    logging_properties definition['logging_properties'] if definition['logging_properties']
    realm_types definition['realm_types'] if definition['realm_types']
    extra_jvm_options definition['config']['jvm_options'] if definition['config']['jvm_options']
    env_variables definition['config']['environment'] if definition['config']['environment']
    init_style definition['config']['init_style'] if definition['config']['init_style']
    system_user system_username if system_username
    system_group system_group if system_group
  end

  Chef::Log.info "Defining GlassFish Domain #{domain_key} - secure_admin"

  # TODO: Merge glassfish_secure_admin into glassfish_domain?
  glassfish_secure_admin "#{domain_key}: secure_admin" do
    domain_name domain_key
    admin_port admin_port if admin_port
    username username if username
    password_file password_file if password_file
    secure secure if secure
    system_user system_username if system_username
    system_group system_group if system_group
    init_style definition['config']['init_style'] if definition['config']['init_style']
    action ('true' == definition['config']['remote_access'].to_s) ? :enable : :disable
  end

  if admin_port
    require 'net/https'

    Chef::Log.info "Defining GlassFish Domain #{domain_key} - wait till up"

    ruby_block "block_until_glassfish_#{domain_key}_up" do
      block do
        count = 0
        loop do
          raise "GlassFish failed to become operational" if count > 50
          count = count + 1
          admin_url = "https://#{node['ipaddress']}:#{admin_port}/management/domain/nodes"
          begin
            uri = URI(admin_url)
            res = nil
            http = Net::HTTP.new(uri.hostname, uri.port)
            http.use_ssl = true
            http.verify_mode = OpenSSL::SSL::VERIFY_NONE
            http.start do |http|
              request = Net::HTTP::Get.new(uri.request_uri)
              request.basic_auth username, definition['config']['password']
              request['Accept'] = "application/json"
              res = http.request(request)
            end
            break if res.kind_of?(Net::HTTPOK)
            puts "GlassFish not responding OK - #{res}"
          rescue Exception => e
            puts "GlassFish error while accessing web interface at #{admin_url}"
            puts e.message
            puts e.backtrace.join("\n")
          end
          sleep 1
        end
      end
      action :create
    end
  end

  Chef::Log.info "Defining GlassFish Domain #{domain_key} - extra_libs"

  if definition['extra_libraries']
    gf_sort(definition['extra_libraries']).values.each do |config|
      config = config.is_a?(Hash) ? config : {'url' => config}
      url = config['url']
      library_type = config['type'] || 'ext'
      requires_restart = config['requires_restart'] || false
      glassfish_library url do
        domain_name domain_key
        admin_port admin_port if admin_port
        username username if username
        password_file password_file if password_file
        secure secure if secure
        system_user system_username if system_username
        system_group system_group if system_group
        library_type library_type
        requires_restart requires_restart
        init_style definition['config']['init_style'] if definition['config']['init_style']
      end
    end
  end

  Chef::Log.info "Defining GlassFish Domain #{domain_key} - properties"

  if definition['properties']
    gf_sort(definition['properties']).each_pair do |key, value|
      glassfish_property "#{key}=#{value}" do
        domain_name domain_key
        admin_port admin_port if admin_port
        username username if username
        password_file password_file if password_file
        secure secure if secure
        system_user system_username if system_username
        system_group system_group if system_group
        key key
        value value.to_s
      end
    end
  end

  ##
  ## Deploy all OSGi bundles prior to attempting to setup resources as they are likely to be the things
  ## that are provided by OSGi
  ##
  Chef::Log.info "Defining GlassFish Domain #{domain_key} - deployables"
  if definition['deployables']
    gf_sort(definition['deployables']).each_pair do |component_name, configuration|
      if configuration['type'] && configuration['type'].to_s == 'osgi'
        if configuration['recipes'] && configuration['recipes']['before']
          gf_sort(configuration['recipes']['before']).each_pair do |recipe, config|
            Chef::Log.info "Including '#{component_name}' application 'before' recipe '#{recipe}' Priority: #{gf_priority(config)}"
            include_recipe recipe
          end
        end
        glassfish_deployable component_name.to_s do
          domain_name domain_key
          admin_port admin_port if admin_port
          username username if username
          password_file password_file if password_file
          secure secure if secure
          system_user system_username if system_username
          system_group system_group if system_group
          version configuration['version']
          url configuration['url']
          type :osgi
        end
        if configuration['recipes'] && configuration['recipes']['after']
          gf_sort(configuration['recipes']['after']).each_pair do |recipe, config|
            Chef::Log.info "Including '#{component_name}' application 'after' recipe '#{recipe}' Priority: #{gf_priority(config)}"
            include_recipe recipe
          end
        end
      end
    end
  end

  Chef::Log.info "Defining GlassFish Domain #{domain_key} - realms"
  if definition['realms']
    gf_sort(definition['realms']).each_pair do |key, configuration|
      glassfish_auth_realm key.to_s do
        domain_name domain_key
        admin_port admin_port if admin_port
        username username if username
        password_file password_file if password_file
        secure secure if secure
        system_user system_username if system_username
        system_group system_group if system_group
        target configuration['target'] if configuration['target']
        classname configuration['classname'] if configuration['classname']
        jaas_context configuration['jaas_context'] if configuration['jaas_context']
        assign_groups configuration['assign_groups'] if configuration['assign_groups']
        properties configuration['properties'] if configuration['properties']
      end
    end
  end

  Chef::Log.info "Defining GlassFish Domain #{domain_key} - jdbc_connection_pools"

  if definition['jdbc_connection_pools']
    gf_sort(definition['jdbc_connection_pools']).each_pair do |key, configuration|
      pool_name = key.to_s
      glassfish_jdbc_connection_pool pool_name do
        domain_name domain_key
        admin_port admin_port if admin_port
        username username if username
        password_file password_file if password_file
        secure secure if secure
        system_user system_username if system_username
        system_group system_group if system_group
        configuration['config'].each_pair do |config_key, value|
          self.send(config_key, value)
        end if configuration['config']
      end
      if configuration['resources']
        gf_sort(configuration['resources']).each_pair do |resource_name, resource_configuration|
          glassfish_jdbc_resource resource_name.to_s do
            domain_name domain_key
            admin_port admin_port if admin_port
            username username if username
            password_file password_file if password_file
            secure secure if secure
            system_user system_username if system_username
            system_group system_group if system_group
            connectionpoolid pool_name
            resource_configuration.each_pair do |config_key, value|
              self.send(config_key, value) unless config_key == 'priority'
            end
          end
        end
      end
    end
  end

  Chef::Log.info "Defining GlassFish Domain #{domain_key} - resource_adapters"
  if definition['resource_adapters']
    gf_sort(definition['resource_adapters']).each_pair do |resource_adapter_key, resource_configuration|
      resource_adapter_key = resource_adapter_key.to_s
      glassfish_resource_adapter resource_adapter_key do
        domain_name domain_key
        admin_port admin_port if admin_port
        username username if username
        password_file password_file if password_file
        secure secure if secure
        system_user system_username if system_username
        system_group system_group if system_group
        resource_configuration['config'].each_pair do |config_key, value|
          self.send(config_key, value)
        end if resource_configuration['config']
      end
      if resource_configuration['connection_pools']
        gf_sort(resource_configuration['connection_pools']).each_pair do |pool_key, pool_configuration|
          pool_key = pool_key.to_s
          glassfish_connector_connection_pool pool_key do
            domain_name domain_key
            admin_port admin_port if admin_port
            username username if username
            password_file password_file if password_file
            secure secure if secure
            system_user system_username if system_username
            system_group system_group if system_group
            raname resource_adapter_key
            pool_configuration['config'].each_pair do |config_key, value|
              self.send(config_key, value)
            end if pool_configuration['config']
          end
          if pool_configuration['resources']
            gf_sort(pool_configuration['resources']).each_pair do |resource_name, resource_configuration|
              glassfish_connector_resource resource_name.to_s do
                domain_name domain_key
                admin_port admin_port if admin_port
                username username if username
                password_file password_file if password_file
                secure secure if secure
                system_user system_username if system_username
                system_group system_group if system_group
                poolname pool_key.to_s
                resource_configuration.each_pair do |config_key, value|
                  self.send(config_key, value) unless config_key == 'priority'
                end
              end
            end
          end
        end
      end
      if resource_configuration['admin_objects']
        gf_sort(resource_configuration['admin_objects']).each_pair do |admin_object_key, admin_object_configuration|
          admin_object_key = admin_object_key.to_s
          glassfish_admin_object admin_object_key do
            domain_name domain_key
            admin_port admin_port if admin_port
            username username if username
            password_file password_file if password_file
            secure secure if secure
            system_user system_username if system_username
            system_group system_group if system_group
            raname resource_adapter_key
            admin_object_configuration.each_pair do |config_key, value|
              self.send(config_key, value) unless config_key == 'priority'
            end
          end
        end
      end
    end
  end

  Chef::Log.info "Defining GlassFish Domain #{domain_key} - custom_resources"
  if definition['custom_resources']
    gf_sort(definition['custom_resources']).each_pair do |key, value|
      hash = value.is_a?(Hash) ? value : {'value' => value}
      glassfish_custom_resource key.to_s do
        domain_name domain_key
        admin_port admin_port if admin_port
        username username if username
        password_file password_file if password_file
        secure secure if secure
        system_user system_username if system_username
        system_group system_group if system_group
        target hash['target'] if hash['target']
        enabled hash['enabled'] if hash['enabled']
        description hash['description'] if hash['description']
        properties hash['properties'] if hash['properties']
        restype hash['restype'] if hash['restype']
        factoryclass hash['factoryclass'] if hash['factoryclass']
        value hash['value'].to_s if hash['value']
      end
    end
  end

  Chef::Log.info "Defining GlassFish Domain #{domain_key} - javamail_resources"
  if definition['javamail_resources']
    gf_sort(definition['javamail_resources']).each_pair do |key, javamail_configuration|
      glassfish_javamail_resource key.to_s do
        domain_name domain_key
        admin_port admin_port if admin_port
        username username if username
        password_file password_file if password_file
        secure secure if secure
        system_user system_username if system_username
        system_group system_group if system_group
        javamail_configuration.each_pair do |config_key, value|
          self.send(config_key, value) unless config_key == 'priority'
        end
      end
    end
  end

  Chef::Log.info "Defining GlassFish Domain #{domain_key} - deployables"
  if definition['deployables']
    gf_sort(definition['deployables']).each_pair do |component_name, configuration|
      if configuration['type'].nil? || configuration['type'].to_s != 'osgi'
        if configuration['recipes'] && configuration['recipes']['before']
          gf_sort(configuration['recipes']['before']).each_pair do |recipe, config|
            include_recipe recipe
          end
        end
        glassfish_deployable component_name.to_s do
          domain_name domain_key
          admin_port admin_port if admin_port
          username username if username
          password_file password_file if password_file
          secure secure if secure
          system_user system_username if system_username
          system_group system_group if system_group
          version configuration['version']
          url configuration['url']
          context_root configuration['context_root'] if configuration['context_root']
          target configuration['target'] if configuration['target']
          enabled configuration['enabled'] if configuration['enabled']
          generate_rmi_stubs configuration['generate_rmi_stubs'] if configuration['generate_rmi_stubs']
          virtual_servers configuration['virtual_servers'] if configuration['virtual_servers']
          availability_enabled configuration['availability_enabled'] if configuration['availability_enabled']
          keep_state configuration['keep_state'] if configuration['keep_state']
          verify configuration['verify'] if configuration['verify']
          precompile_jsp configuration['precompile_jsp'] if configuration['precompile_jsp']
          async_replication configuration['async_replication'] if configuration['async_replication']
          properties configuration['properties'] if configuration['properties']
          descriptors configuration['descriptors'] if configuration['descriptors']
          lb_enabled configuration['lb_enabled'] if configuration['lb_enabled']
        end
        if configuration['web_env_entries']
          gf_sort(configuration['web_env_entries']).each_pair do |key, value|
            hash = value.is_a?(Hash) ? value : {'value' => value}
            glassfish_web_env_entry "#{domain_key}: #{component_name} set #{key}" do
              domain_name domain_key
              admin_port admin_port if admin_port
              username username if username
              password_file password_file if password_file
              secure secure if secure
              system_user system_username if system_username
              system_group system_group if system_group
              webapp component_name
              name key
              type hash['type'] if hash['type']
              value hash['value'].to_s if hash['value']
              description hash['description'] if hash['description']
            end
          end
        end
        if configuration['recipes'] && configuration['recipes']['after']
          gf_sort(configuration['recipes']['after']).each_pair do |recipe, config|
            include_recipe recipe
          end
        end
      end
    end
  end

  Chef::Log.info "Defining GlassFish Domain #{domain_key} - scanning existing applications"
  gf_scan_existing_resources(admin_port,
                             username,
                             password_file,
                             secure,
                             'list-applications') do |versioned_component_name|
    Chef::Log.info "Defining GlassFish Domain #{domain_key} - scanning existing application #{versioned_component_name}"
    name_parts = versioned_component_name.split(':')
    key = name_parts[0]
    version_parts = name_parts.size > 1 ? name_parts[1].split('+') : ['']
    version = version_parts[0]
    plan_version = name_parts.size > 1 ? version_parts[1] : nil

    keep = false
    if definition['deployables']
      if definition['deployables'][key]
        config = definition['deployables'][key]
        if config['type'].to_s != 'osgi'
          if config['version'] == version || Digest::SHA1.hexdigest(config['url']) == version
            if (!plan_version && (!config['descriptors'] || config['descriptors'].empty?)) ||
              (Asadmin.generate_component_plan_digest(config['descriptors']) == plan_version)
              keep = true
            end
          end
        end
      end

      definition['deployables'].keys.each do |key|
        config = definition['deployables'][key]
        # OSGi does not keep the version in the name so we need to store it on the filesystem
        if config['type'].to_s == 'osgi'
          candidate_name = Asadmin.versioned_component_name(key, config['type'], config['version'], config['url'], nil )
          if candidate_name == versioned_component_name
            keep = true
            break
          end
        end
      end
    end

    unless keep
      Chef::Log.info "Defining GlassFish Domain #{domain_key} - undeploying existing resource #{versioned_component_name}"
      glassfish_deployable versioned_component_name do
        domain_name domain_key
        admin_port admin_port if admin_port
        username username if username
        password_file password_file if password_file
        secure secure if secure
        system_user system_username if system_username
        system_group system_group if system_group
        action :undeploy
      end
    end
  end

  Chef::Log.info "Defining GlassFish Domain #{domain_key} - checking web-env entry for existing resources"

  if definition['deployables']
    gf_sort(definition['deployables']).each_pair do |component_name, configuration|
      next if configuration['type'] && configuration['type'].to_s == 'osgi'
      Chef::Log.info "Defining GlassFish Domain #{domain_key} - checking web-env entry for #{component_name}"
      gf_scan_existing_resources(admin_port,
                                 username,
                                 password_file,
                                 secure,
                                 "list-web-env-entry #{component_name}") do |existing|
        unless configuration['web_env_entries'] && configuration['web_env_entries'][existing]
          Chef::Log.info "Defining GlassFish Domain #{domain_key} - unsetting #{existing} web-env entry for #{component_name}"
          glassfish_web_env_entry "#{domain_key}: #{component_name} unset #{existing}" do
            domain_name domain_key
            admin_port admin_port if admin_port
            username username if username
            password_file password_file if password_file
            secure secure if secure
            system_user system_username if system_username
            system_group system_group if system_group
            webapp component_name
            name existing
            action :unset
          end
        end
      end
    end
  end

  Chef::Log.info "Defining GlassFish Domain #{domain_key} - checking resource adapter configs for existing resources"
  gf_scan_existing_resources(admin_port,
                             username,
                             password_file,
                             secure,
                             'list-resource-adapter-configs') do |existing|
    Chef::Log.info "Defining GlassFish Domain #{domain_key} - checking resource adapter config for #{existing}"
    unless definition['resource_adapters'] && definition['resource_adapters'][existing]
      Chef::Log.info "Defining GlassFish Domain #{domain_key} - removing resource adapter config for #{existing}"
      glassfish_resource_adapter existing do
        domain_name domain_key
        admin_port admin_port if admin_port
        username username if username
        password_file password_file if password_file
        secure secure if secure
        system_user system_username if system_username
        system_group system_group if system_group
        action :delete
      end
    end
  end

  Chef::Log.info "Defining GlassFish Domain #{domain_key} - checking existing connector pools"
  gf_scan_existing_resources(admin_port,
                             username,
                             password_file,
                             secure,
                             'list-connector-connection-pools') do |existing|
    Chef::Log.info "Defining GlassFish Domain #{domain_key} - considering existing connector pool #{existing}"
    found = false
    if definition['resource_adapters']
      gf_sort(definition['resource_adapters']).each_pair do |key, configuration|
        if configuration['connection_pools'] && configuration['connection_pools'][existing]
          found = true
        end
      end
    end
    unless found
      Chef::Log.info "Defining GlassFish Domain #{domain_key} - removing existing connector pool #{existing}"
      glassfish_connector_connection_pool existing do
        domain_name domain_key
        admin_port admin_port if admin_port
        username username if username
        password_file password_file if password_file
        secure secure if secure
        system_user system_username if system_username
        system_group system_group if system_group
        action :delete
      end
    end
  end

  Chef::Log.info "Defining GlassFish Domain #{domain_key} - checking existing resource connectors"
  gf_scan_existing_resources(admin_port, username, password_file, secure, 'list-connector-resources') do |existing|
    Chef::Log.info "Defining GlassFish Domain #{domain_key} - considering existing resource connector #{existing}"
    found = false
    if definition['resource_adapters']
      gf_sort(definition['resource_adapters']).each_pair do |key, configuration|
        if configuration['connection_pools']
          gf_sort(configuration['connection_pools']).each_pair do |pool_name, pool_configuration|
            if pool_configuration['resources'] && pool_configuration['resources'][existing]
              found = true
            end
          end
        end
      end
    end
    unless found
      Chef::Log.info "Defining GlassFish Domain #{domain_key} - removing existing resource connector #{existing}"
      glassfish_connector_resource existing do
        domain_name domain_key
        admin_port admin_port if admin_port
        username username if username
        password_file password_file if password_file
        secure secure if secure
        system_user system_username if system_username
        system_group system_group if system_group
        action :delete
      end
    end
  end

  Chef::Log.info "Defining GlassFish Domain #{domain_key} - checking existing admin objects"
  gf_scan_existing_resources(admin_port, username, password_file, secure, 'list-admin-objects') do |existing|
    Chef::Log.info "Defining GlassFish Domain #{domain_key} - considering existing admin object #{existing}"
    found = false
    if definition['resource_adapters']
      gf_sort(definition['resource_adapters']).each_pair do |key, configuration|
        if configuration['admin_objects'] && configuration['admin_objects'][existing]
          found = true
        end
      end
    end
    unless found
      Chef::Log.info "Defining GlassFish Domain #{domain_key} - removing existing admin object #{existing}"
      glassfish_admin_object existing do
        domain_name domain_key
        admin_port admin_port if admin_port
        username username if username
        password_file password_file if password_file
        secure secure if secure
        system_user system_username if system_username
        system_group system_group if system_group
        action :delete
      end
    end
  end

  Chef::Log.info "Defining GlassFish Domain #{domain_key} - checking existing jdbc pools"
  gf_scan_existing_resources(admin_port, username, password_file, secure, 'list-jdbc-connection-pools') do |existing|
    Chef::Log.info "Defining GlassFish Domain #{domain_key} - considering existing jdbc pool #{existing}"
    standard_pools = %w{__TimerPool}
    unless definition['jdbc_connection_pools'] &&
           definition['jdbc_connection_pools'][existing] ||
           standard_pools.include?(existing)

      Chef::Log.info "Defining GlassFish Domain #{domain_key} - removing existing jdbc pool #{existing}"

      glassfish_jdbc_connection_pool existing do
        domain_name domain_key
        admin_port admin_port if admin_port
        username username if username
        password_file password_file if password_file
        secure secure if secure
        system_user system_username if system_username
        system_group system_group if system_group
        action :delete
      end
    end
  end

  Chef::Log.info "Defining GlassFish Domain #{domain_key} - checking existing jdbc resources"
  gf_scan_existing_resources(admin_port, username, password_file, secure, 'list-jdbc-resources') do |existing|
    Chef::Log.info "Defining GlassFish Domain #{domain_key} - considering existing jdbc resource #{existing}"
    found = false
    if definition['jdbc_connection_pools']
      gf_sort(definition['jdbc_connection_pools']).each_pair do |key, configuration|
        if configuration['resources'] && configuration['resources'][existing]
          found = true
        end
      end
    end
    standard_resources = %w{jdbc/__TimerPool}
    unless found || standard_resources.include?(existing)
      Chef::Log.info "Defining GlassFish Domain #{domain_key} - removing existing jdbc resource #{existing}"
      glassfish_jdbc_connection_pool existing do
        domain_name domain_key
        admin_port admin_port if admin_port
        username username if username
        password_file password_file if password_file
        secure secure if secure
        system_user system_username if system_username
        system_group system_group if system_group
        action :delete
      end
    end
  end

  Chef::Log.info "Defining GlassFish Domain #{domain_key} - checking existing mail resources"
  gf_scan_existing_resources(admin_port, username, password_file, secure, 'list-javamail-resources') do |existing|
    Chef::Log.info "Defining GlassFish Domain #{domain_key} - considering existing mail resource #{existing}"
    unless definition['javamail_resources'] && definition['javamail_resources'][existing]
      Chef::Log.info "Defining GlassFish Domain #{domain_key} - removing existing mail resource #{existing}"
      glassfish_javamail_resource existing do
        domain_name domain_key
        admin_port admin_port if admin_port
        username username if username
        password_file password_file if password_file
        secure secure if secure
        system_user system_username if system_username
        system_group system_group if system_group
        action :delete
      end
    end
  end

  Chef::Log.info "Defining GlassFish Domain #{domain_key} - checking existing custom resources"
  gf_scan_existing_resources(admin_port, username, password_file, secure, 'list-custom-resources') do |existing|
    Chef::Log.info "Defining GlassFish Domain #{domain_key} - considering existing custom resource #{existing}"
    unless definition['custom_resources'] && definition['custom_resources'][existing]
      Chef::Log.info "Defining GlassFish Domain #{domain_key} - removing existing custom resource #{existing}"
      glassfish_custom_resource existing do
        domain_name domain_key
        admin_port admin_port if admin_port
        username username if username
        password_file password_file if password_file
        secure secure if secure
        system_user system_username if system_username
        system_group system_group if system_group
        action :delete
      end
    end
  end

  Chef::Log.info "Defining GlassFish Domain #{domain_key} - checking existing resource adapters"
  gf_scan_existing_resources(admin_port, username, password_file, secure, 'list-resource-adapter-configs') do |existing|
    Chef::Log.info "Defining GlassFish Domain #{domain_key} - considering existing resource adapters #{existing}"
    unless definition['resource_adapters'] && definition['resource_adapters'][existing]
      Chef::Log.info "Defining GlassFish Domain #{domain_key} - removing existing resource adapters #{existing}"
      glassfish_resource_adapter existing do
        domain_name domain_key
        admin_port admin_port if admin_port
        username username if username
        password_file password_file if password_file
        secure secure if secure
        system_user system_username if system_username
        system_group system_group if system_group
        action :delete
      end
    end
  end

  Chef::Log.info "Defining GlassFish Domain #{domain_key} - checking existing auth realms"
  gf_scan_existing_resources(admin_port, username, password_file, secure, 'list-auth-realms') do |existing|
    Chef::Log.info "Defining GlassFish Domain #{domain_key} - considering existing auth realms #{existing}"
    standard_realms = %w{admin-realm file certificate}
    unless definition['realms'] && definition['realms'][existing] || standard_realms.include?(existing)
      Chef::Log.info "Defining GlassFish Domain #{domain_key} - removing existing auth realms #{existing}"
      glassfish_auth_realm existing do
        domain_name domain_key
        admin_port admin_port if admin_port
        username username if username
        password_file password_file if password_file
        secure secure if secure
        system_user system_username if system_username
        system_group system_group if system_group
        action :delete
      end
    end
  end
  Chef::Log.info "Defining GlassFish Domain #{domain_key} - complete"
end

gf_sort(node['glassfish']['domains']).each_pair do |domain_key, definition|
  if definition['recipes'] && definition['recipes']['after']
    gf_sort(definition['recipes']['after']).each_pair do |recipe, config|
      Chef::Log.info "Including domain 'after' recipe '#{recipe}' Priority: #{gf_priority(config)}"
      include_recipe recipe
    end
  end
end

domain_names = node['glassfish']['domains'].keys

Dir["#{node['glassfish']['domains_dir']}/*"].
  select { |file| File.directory?(file) }.
  select { |file| !domain_names.include?(File.basename(file)) }.
  each do |file|

  Chef::Log.info "Removing historic Glassfish Domain #{File.basename(file)}"

  glassfish_domain File.basename(file) do
    action :destroy
  end
end
