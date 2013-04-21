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

  output = `#{Asadmin.asadmin_command(node, command, options)} 2> /dev/null`
  return if output =~ /^Nothing to list.*/ || output =~ /^No such local command.*/
  lines = output.split("\n")

  lines.each do |line|
    existing = line.scan(/^(\S+)/).flatten[0]
    yield existing
  end
end

node['glassfish']['domains'].each_pair do |domain_key, definition|
  if definition['recipes'] && definition['recipes']['before']
    definition['recipes']['before'].each do |recipe|
      include_recipe recipe
    end
  end
end

node['glassfish']['domains'].each_pair do |domain_key, definition|
  domain_key = domain_key.to_s

  Chef::Log.info "Defining GlassFish Domain #{domain_key}"

  admin_port = definition['config']['admin_port']
  username = definition['config']['username']
  secure = definition['config']['secure']
  password_file = username ? "#{node['glassfish']['domains_dir']}/#{domain_key}_admin_passwd" : nil

  if (definition['config']['port'] && definition['config']['port'] < 1024) || (admin_port && admin_port < 1024)
    include_recipe 'authbind'
  end

  glassfish_domain domain_key do
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
  end

  if definition['extra_libraries']
    definition['extra_libraries'].values.each do |config|
      config = config.is_a?(Hash) ? config : {'url' => config}
      url = config['url']
      library_type = config['type'] || 'ext'
      glassfish_library url do
        domain_name domain_key
        admin_port admin_port if admin_port
        username username if username
        password_file password_file if password_file
        secure secure if secure
        library_type library_type
      end
    end
  end

  glassfish_secure_admin "#{domain_key}: secure_admin" do
    domain_name domain_key
    admin_port admin_port if admin_port
    username username if username
    password_file password_file if password_file
    secure secure if secure
    action ('true' == definition['config']['remote_access'].to_s) ? :enable : :disable
  end

  if definition['properties']
    definition['properties'].each_pair do |key, value|
      glassfish_property "#{key}=#{value}" do
        domain_name domain_key
        admin_port admin_port if admin_port
        username username if username
        password_file password_file if password_file
        secure secure if secure
        key key
        value value
      end
    end
  end

  ##
  ## Deploy all OSGi bundles prior to attempting to setup resources as they are likely to be the things
  ## that are provided by OSGi
  ##
  if definition['deployables']
    definition['deployables'].each_pair do |component_name, configuration|
      if configuration['type'] && configuration['type'].to_s == 'osgi'
        glassfish_deployable component_name.to_s do
          domain_name domain_key
          admin_port admin_port if admin_port
          username username if username
          password_file password_file if password_file
          secure secure if secure
          version configuration['version']
          url configuration['url']
          type :osgi
        end
      end
    end
  end

  if definition['realms']
    definition['realms'].each_pair do |key, configuration|
      glassfish_auth_realm key.to_s do
        domain_name domain_key
        admin_port admin_port if admin_port
        username username if username
        password_file password_file if password_file
        secure secure if secure
        target configuration['target'] if configuration['target']
        classname configuration['classname'] if configuration['classname']
        jaas_context configuration['jaas_context'] if configuration['jaas_context']
        assign_groups configuration['assign_groups'] if configuration['assign_groups']
        properties configuration['properties'] if configuration['properties']
      end
    end
  end

  if definition['jdbc_connection_pools']
    definition['jdbc_connection_pools'].each_pair do |key, configuration|
      key = key.to_s
      glassfish_jdbc_connection_pool key do
        domain_name domain_key
        admin_port admin_port if admin_port
        username username if username
        password_file password_file if password_file
        secure secure if secure
        configuration['config'].each_pair do |config_key, value|
          self.send(config_key, value)
        end if configuration['config']
      end
      if configuration['resources']
        configuration['resources'].each_pair do |resource_name, resource_configuration|
          glassfish_jdbc_resource resource_name.to_s do
            domain_name domain_key
            admin_port admin_port if admin_port
            username username if username
            password_file password_file if password_file
            secure secure if secure
            connectionpoolid key
            resource_configuration.each_pair do |config_key, value|
              self.send(config_key, value)
            end
          end
        end
      end
    end
  end

  if definition['resource_adapters']
    definition['resource_adapters'].each_pair do |resource_adapter_key, resource_configuration|
      resource_adapter_key = resource_adapter_key.to_s
      glassfish_resource_adapter resource_adapter_key do
        domain_name domain_key
        admin_port admin_port if admin_port
        username username if username
        password_file password_file if password_file
        secure secure if secure
        resource_configuration['config'].each_pair do |config_key, value|
          self.send(config_key, value)
        end if resource_configuration['config']
      end
      if resource_configuration['connection_pools']
        resource_configuration['connection_pools'].each_pair do |pool_key, pool_configuration|
          pool_key = pool_key.to_s
          glassfish_connector_connection_pool pool_key do
            domain_name domain_key
            admin_port admin_port if admin_port
            username username if username
            password_file password_file if password_file
            secure secure if secure
            raname resource_adapter_key
            pool_configuration['config'].each_pair do |config_key, value|
              self.send(config_key, value)
            end if pool_configuration['config']
          end
          if pool_configuration['resources']
            pool_configuration['resources'].each_pair do |resource_name, resource_configuration|
              glassfish_connector_resource resource_name.to_s do
                domain_name domain_key
                admin_port admin_port if admin_port
                username username if username
                password_file password_file if password_file
                secure secure if secure
                poolname pool_key.to_s
                resource_configuration.each_pair do |config_key, value|
                  self.send(config_key, value)
                end
              end
            end
          end
        end
      end
      if resource_configuration['admin_objects']
        resource_configuration['admin_objects'].each_pair do |admin_object_key, admin_object_configuration|
          admin_object_key = admin_object_key.to_s
          glassfish_admin_object admin_object_key do
            domain_name domain_key
            admin_port admin_port if admin_port
            username username if username
            password_file password_file if password_file
            secure secure if secure
            raname resource_adapter_key
            admin_object_configuration.each_pair do |config_key, value|
              self.send(config_key, value)
            end
          end
        end
      end
    end
  end

  if definition['custom_resources']
    definition['custom_resources'].each_pair do |key, value|
      hash = value.is_a?(Hash) ? value : {'value' => value}
      glassfish_custom_resource key.to_s do
        domain_name domain_key
        admin_port admin_port if admin_port
        username username if username
        password_file password_file if password_file
        secure secure if secure
        target hash['target'] if hash['target']
        enabled hash['enabled'] if hash['enabled']
        description hash['description'] if hash['description']
        properties hash['properties'] if hash['properties']
        restype hash['restype'] if hash['restype']
        restype hash['factoryclass'] if hash['factoryclass']
        value hash['value'] if hash['value']
      end
    end
  end

  if definition['javamail_resources']
    definition['javamail_resources'].each_pair do |key, javamail_configuration|
      glassfish_javamail_resource key.to_s do
        domain_name domain_key
        admin_port admin_port if admin_port
        username username if username
        password_file password_file if password_file
        secure secure if secure
        javamail_configuration.each_pair do |config_key, value|
          self.send(config_key, value)
        end
      end
    end
  end

  if definition['deployables']
    definition['deployables'].each_pair do |component_name, configuration|
      if configuration['type'].nil? || configuration['type'].to_s != 'osgi'
        glassfish_deployable component_name.to_s do
          domain_name domain_key
          admin_port admin_port if admin_port
          username username if username
          password_file password_file if password_file
          secure secure if secure
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
          configuration['web_env_entries'].each_pair do |key, value|
            hash = value.is_a?(Hash) ? value : {'value' => value}
            glassfish_web_env_entry "#{domain_key}: #{component_name} set #{key}" do
              domain_name domain_key
              admin_port admin_port if admin_port
              username username if username
              password_file password_file if password_file
              secure secure if secure
              webapp component_name
              name key
              type hash['type'] if hash['type']
              value hash['value'] if hash['value']
              description hash['description'] if hash['description']
            end
          end
        end
      end
    end
  end

  gf_scan_existing_resources(admin_port,
                             username,
                             password_file,
                             secure,
                             'list-applications') do |versioned_component_name|
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
      glassfish_deployable versioned_component_name do
        domain_name domain_key
        admin_port admin_port if admin_port
        username username if username
        password_file password_file if password_file
        secure secure if secure
        action :undeploy
      end
    end
  end

  if definition['deployables']
    definition['deployables'].each_pair do |component_name, configuration|
      next if configuration['type'] && configuration['type'].to_s == 'osgi'
      gf_scan_existing_resources(admin_port,
                                 username,
                                 password_file,
                                 secure,
                                 "list-web-env-entry #{component_name}") do |existing|
        unless configuration['web_env_entries'] && configuration['web_env_entries'][existing]
          glassfish_web_env_entry "#{domain_key}: #{component_name} unset #{existing}" do
            domain_name domain_key
            admin_port admin_port if admin_port
            username username if username
            password_file password_file if password_file
            secure secure if secure
            webapp component_name
            name existing
            action :unset
          end
        end
      end
    end
  end

  gf_scan_existing_resources(admin_port,
                             username,
                             password_file,
                             secure,
                             'list-resource-adapter-configs') do |existing|
    unless definition['resource_adapters'] && definition['resource_adapters'][existing]
      glassfish_resource_adapter existing do
        domain_name domain_key
        admin_port admin_port if admin_port
        username username if username
        password_file password_file if password_file
        secure secure if secure
        action :delete
      end
    end
  end

  gf_scan_existing_resources(admin_port,
                             username,
                             password_file,
                             secure,
                             'list-connector-connection-pools') do |existing|
    found = false
    if definition['resource_adapters']
      definition['resource_adapters'].each_pair do |key, configuration|
        if configuration['connection_pools'] && configuration['connection_pools'][existing]
          found = true
        end
      end
    end
    unless found
      glassfish_connector_connection_pool existing do
        domain_name domain_key
        admin_port admin_port if admin_port
        username username if username
        password_file password_file if password_file
        secure secure if secure
        action :delete
      end
    end
  end

  gf_scan_existing_resources(admin_port, username, password_file, secure, 'list-connector-resources') do |existing|
    found = false
    if definition['resource_adapters']
      definition['resource_adapters'].each_pair do |key, configuration|
        if configuration['connection_pools']
          configuration['connection_pools'].each_pair do |pool_name, pool_configuration|
            if pool_configuration['resources'] && pool_configuration['resources'][existing]
              found = true
            end
          end
        end
      end
    end
    unless found
      glassfish_connector_resource existing do
        domain_name domain_key
        admin_port admin_port if admin_port
        username username if username
        password_file password_file if password_file
        secure secure if secure
        action :delete
      end
    end
  end

  gf_scan_existing_resources(admin_port, username, password_file, secure, 'list-admin-objects') do |existing|
    found = false
    if definition['resource_adapters']
      definition['resource_adapters'].each_pair do |key, configuration|
        if configuration['admin_objects'] && configuration['admin_objects'][existing]
          found = true
        end
      end
    end
    unless found
      glassfish_admin_object existing do
        domain_name domain_key
        admin_port admin_port if admin_port
        username username if username
        password_file password_file if password_file
        secure secure if secure
        action :delete
      end
    end
  end

  gf_scan_existing_resources(admin_port, username, password_file, secure, 'list-jdbc-connection-pools') do |existing|
    standard_pools = %w{__TimerPool}
    unless definition['jdbc_connection_pools'] &&
           definition['jdbc_connection_pools'][existing] ||
           standard_pools.include?(existing)

      glassfish_jdbc_connection_pool existing do
        domain_name domain_key
        admin_port admin_port if admin_port
        username username if username
        password_file password_file if password_file
        secure secure if secure
        action :delete
      end
    end
  end

  gf_scan_existing_resources(admin_port, username, password_file, secure, 'list-jdbc-resources') do |existing|
    found = false
    if definition['jdbc_connection_pools']
      definition['jdbc_connection_pools'].each_pair do |key, configuration|
        if configuration['resources'] && configuration['resources'][existing]
          found = true
        end
      end
    end
    standard_resources = %w{jdbc/__TimerPool}
    unless found || standard_resources.include?(existing)
      glassfish_jdbc_connection_pool existing do
        domain_name domain_key
        admin_port admin_port if admin_port
        username username if username
        password_file password_file if password_file
        secure secure if secure
        action :delete
      end
    end
  end

  gf_scan_existing_resources(admin_port, username, password_file, secure, 'list-javamail-resources') do |existing|
    unless definition['javamail_resources'] && definition['javamail_resources'][existing]
      glassfish_javamail_resource existing do
        domain_name domain_key
        admin_port admin_port if admin_port
        username username if username
        password_file password_file if password_file
        secure secure if secure
        action :delete
      end
    end
  end

  gf_scan_existing_resources(admin_port, username, password_file, secure, 'list-custom-resources') do |existing|
    unless definition['custom_resources'] && definition['custom_resources'][existing]
      glassfish_custom_resource existing do
        domain_name domain_key
        admin_port admin_port if admin_port
        username username if username
        password_file password_file if password_file
        secure secure if secure
        action :delete
      end
    end
  end

  gf_scan_existing_resources(admin_port, username, password_file, secure, 'list-resource-adapter-configs') do |existing|
    unless definition['resource_adapters'] && definition['resource_adapters'][existing]
      glassfish_resource_adapter existing do
        domain_name domain_key
        admin_port admin_port if admin_port
        username username if username
        password_file password_file if password_file
        secure secure if secure
        action :delete
      end
    end
  end

  gf_scan_existing_resources(admin_port, username, password_file, secure, 'list-auth-realms') do |existing|
    standard_realms = %w{admin-realm file certificate}
    unless definition['realms'] && definition['realms'][existing] || standard_realms.include?(existing)
      glassfish_auth_realm existing do
        domain_name domain_key
        admin_port admin_port if admin_port
        username username if username
        password_file password_file if password_file
        secure secure if secure
        action :delete
      end
    end
  end
end

node['glassfish']['domains'].each_pair do |domain_key, definition|
  if definition['recipes'] && definition['recipes']['after']
    definition['recipes']['after'].each do |recipe|
      include_recipe recipe
    end
  end
end
