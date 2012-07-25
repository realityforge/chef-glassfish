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

include_recipe "glassfish::default"

node['glassfish']['domains'].each_pair do |domain_key, definition|
  domain_key = domain_key.to_s

  Chef::Log.info "Defining GlassFish Domain #{domain_key}"

  admin_port = definition['config']['admin_port']
  username = definition['config']['username']
  secure = definition['config']['secure']
  password_file = username ? "#{node['glassfish']['domains_dir']}/#{domain_key}_admin_passwd" : nil

  if (definition['config']['port'] && definition['config']['port'] < 1024) || (admin_port && admin_port < 1024)
    include_recipe "authbind"
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
    extra_libraries definition['extra_libraries'] if definition['extra_libraries']
    logging_properties definition['logging_properties'] if definition['logging_properties']
    realm_types definition['realm_types'] if definition['realm_types']
    extra_jvm_options definition['config']['jvm_options'] if definition['config']['jvm_options']
  end

  glassfish_secure_admin "#{domain_key}: secure_admin" do
    domain_name domain_key
    admin_port admin_port if admin_port
    username username if username
    password_file password_file if password_file
    secure secure if secure
    action ('true' == definition['config']['remote_access'].to_s) ? :enable : :disable
  end

  if definition['jvm_options']
    definition['jvm_options'].each do |jvm_option|
      glassfish_jvm_option jvm_option do
        domain_name domain_key
        admin_port admin_port if admin_port
        username username if username
        password_file password_file if password_file
        secure secure if secure
      end
    end
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
        jaas_context configuration['jaas-context'] if configuration['jaas-context']
        assign_groups configuration['assign-groups'] if configuration['assign-groups']
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
end
