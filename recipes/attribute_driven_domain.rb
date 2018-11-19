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

A typical approach is to define the configuration for the entire application on the node and include the recipe.
Another approach using a vagrant file is to set the json attribute such as;

```ruby
  chef.json = {
        "java" => {
            "install_flavor" => "oracle",
            "jdk_version" => 7,
            "oracle" => {
                "accept_oracle_download_terms" => true
            }
        },
        "glassfish" => {
            "version" => "4.0.1",
            "package_url" => "http://dlc.sun.com.edgesuite.net/glassfish/4.0.1/promoted/glassfish-4.0.1-b01.zip",
            "base_dir" => "/usr/local/glassfish",
            "domains_dir" => "/usr/local/glassfish/glassfish/domains",
            "domains" => {
                "myapp" => {
                    "config" => {
                        "min_memory" => 1024,
                        "max_memory" => 1024,
                        "max_perm_size" => 256,
                        "port" => 7070,
                        "admin_port" => 4848,
                        "username" => "adminuser",
                        "password" => "adminpw",
                        "master_password" => "mykeystorepassword",
                        "remote_access" => false,
                        "jvm_options" => ["-DMYAPP_CONFIG_DIR=/usr/local/myapp/config", "-Dcom.sun.enterprise.tools.admingui.NO_NETWORK=true"],
                        "secure" => false
                    },
                    'extra_libraries' => {
                        'realm' => {
                          'type' => 'common',
                          'url' => 'https://s3.amazonaws.com/somebucket/lib/realm.jar',
                          'requires_restart' => true
                        },
                        'jdbcdriver' => {
                          'type' => 'common',
                          'url' => 'https://s3.amazonaws.com/somebucket/lib/mysql-connector-java-5.1.25-bin.jar'
                        },
                        'encryption' => {
                          'type' => 'common',
                          'url' => 'https://s3.amazonaws.com/somebucket/lib/jasypt-1.9.0.jar'
                        }
                    },
                    'threadpools' => {
                      'thread-pool-1' => {
                        'maxthreadpoolsize' => 200,
                        'minthreadpoolsize' => 5,
                        'idletimeout' => 900,
                        'maxqueuesize' => 4096
                      },
                      'http-thread-pool' => {
                        'maxthreadpoolsize' => 200,
                        'minthreadpoolsize' => 5,
                        'idletimeout' => 900,
                        'maxqueuesize' => 4096
                      },
                      'admin-pool' => {
                        'maxthreadpoolsize' => 50,
                        'minthreadpoolsize' => 5,
                        'maxqueuesize' => 256
                      }
                    },
                    'iiop_listeners' => {
                      'orb-listener-1' => {
                        'enabled' => true,
                        'iiopport' => 1072,
                        'securityenabled' => false
                      }
                    },
                    'context_services' => {
                      'concurrent/MyAppContextService' => {
                        'description' => 'My Apps ContextService'
                      }
                    },
                    'managed_thread_factories' => {
                      'concurrent/myThreadFactory' => {
                        'threadpriority' => 12,
                        'description' => 'My Thread Factory'
                      }
                    },
                    'managed_executor_services' => {
                      'concurrent/myExecutorService' => {
                        'threadpriority' => 12,
                        'description' => 'My Executor Service'
                      }
                    },
                    'managed_scheduled_executor_services' => {
                      'concurrent/myScheduledExecutorService' => {
                        'corepoolsize' => 12,
                        'description' => 'My Executor Service'
                      }
                    },
                    'jdbc_connection_pools' => {
                        'RealmPool' => {
                            'config' => {
                                'datasourceclassname' => 'com.mysql.jdbc.jdbc2.optional.MysqlDataSource',
                                'restype' => 'javax.sql.DataSource',
                                'isconnectvalidatereq' => 'true',
                                'validationmethod' => 'auto-commit',
                                'ping' => 'true',
                                'description' => 'Realm Pool',
                                'properties' => {
                                   'Instance' => "jdbc:mysql://devdb.somecompany.com:3306/realmdb",
                                   'ServerName' => "devdb.somecompany.com",
                                   'User' => 'realmuser',
                                   'Password' => 'realmpw',
                                   'PortNumber' => '3306',
                                   'DatabaseName' => 'realmdb'
                                }
                            },
                            'resources' => {
                                'jdbc/Realm' => {
                                    'description' => 'Resource for Realm Pool',
                                }
                            }
                        },
                        'AppPool' => {
                            'config' => {
                                'datasourceclassname' => 'com.mysql.jdbc.jdbc2.optional.MysqlDataSource',
                                'restype' => 'javax.sql.DataSource',
                                'isconnectvalidatereq' => 'true',
                                'validationmethod' => 'auto-commit',
                                'ping' => 'true',
                                'description' => 'App Pool',
                                'properties' => {
                                  'Instance' => "jdbc:mysql://devdb.somecompany.com:3306/appdb",
                                  'ServerName' => "devdb.somecompany.com",
                                  'User' => 'appuser',
                                  'Password' => 'apppw',
                                  'PortNumber' => '3306',
                                  'DatabaseName' => 'appdb'
                                }
                            },
                            'resources' => {
                                'jdbc/App' => {
                                    'description' => 'Resource for App Pool',
                                }
                            }
                        }
                    },
                    'realms' => {
                        'custom-realm' => {
                            'classname' => 'com.somecompany.realm.CustomRealm',
                            'jaas-context' => 'customRealm',
                            'properties' => {
                                'jaas-context' => 'customRealm',
                                'datasource' => 'jdbc/Realm',
                                'groupQuery' => 'SELECT ...',
                                'passwordQuery' => 'SELECT ...'
                            }
                         }
                    },
                    'realm_types' => {
                        'customRealm' => 'com.somecompany.realm.CustomLoginModule'
                    },
                    'deployables' => {
                        'myapp' => {
                            'url' => 'https://s3.amazonaws.com/somebucket/apps/app.war',
                            'context_root' => '/'
                         }
                    },
                    "custom_resources" => {
                      "env/myapp/timeout" => {
                        "restype" => "java.lang.Long",
                        "value" => 300000
                      },
                      "env/myapp/mykey" => "123",
                      "env/myapp/someString" => "XYZ"
                    }
                }
            }
        }
```
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
      # CLI031 Warnings are a result of internal changes in glassfish and we can not control them
      Chef::Log.warn "Ignoring asadmin output: #{line}" unless (line =~/CLI031: Warning.*/)
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
  return {} if hash.nil?
  hash = hash.dup
  hash.delete_if { |k, v| k =~ /^_.*/ || k == 'managed' }
  Hash[hash.sort_by { |key, value| "#{'%04d' % gf_priority(value)}#{key}" }]
end

def gf_managed?(data)
  (data.nil? || data['managed'].nil?) ? true : !!data['managed']
end

gf_sort(node['glassfish']['domains']).each_pair do |domain_key, definition|
  RealityForge::GlassFish.set_current_domain(node, domain_key)
  if definition['recipes'] && definition['recipes']['before']
    gf_sort(definition['recipes']['before']).each_pair do |recipe, config|
      Chef::Log.info "Including domain 'before' recipe '#{recipe}' Priority: #{gf_priority(config)}"
      include_recipe recipe
    end
  end
  RealityForge::GlassFish.set_current_domain(node, nil)
end

gf_sort(node['glassfish']['domains']).each_pair do |domain_key, definition|
  domain_key = domain_key.to_s

  RealityForge::GlassFish.set_current_domain(node, domain_key)

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

  if definition['config']['portbase']
    if definition['config']['admin_port']
      fail 'Glassfish admin port is automatically calculated from portbase. Please do not set both.'
    end
    portbase = definition['config']['portbase']
    admin_port = portbase + 48
  end

  Chef::Log.info "Defining GlassFish Domain #{domain_key} - domain"

  domain = glassfish_domain domain_key do
    min_memory definition['config']['min_memory'] if definition['config']['min_memory']
    max_memory definition['config']['max_memory'] if definition['config']['max_memory']
    max_perm_size definition['config']['max_perm_size'] if definition['config']['max_perm_size']
    max_stack_size definition['config']['max_stack_size'] if definition['config']['max_stack_size']
    port definition['config']['port'] if definition['config']['port']
    admin_port admin_port if admin_port
    portbase portbase if portbase
    username username if username
    password_file password_file if password_file
    secure secure if secure
    password definition['config']['password'] if definition['config']['password']
    master_password definition['config']['master_password'] if definition['config']['master_password']
    logging_properties definition['logging_properties'] if definition['logging_properties']
    realm_types definition['realm_types'] if definition['realm_types']
    extra_jvm_options definition['config']['jvm_options'] if definition['config']['jvm_options']
    env_variables definition['config']['environment'] if definition['config']['environment']
    env_var_file definition['config']['environment_file'] if definition['config']['environment_file']
    systemd_enabled definition['config']['systemd_enabled'] if definition['config']['systemd_enabled']
    systemd_start_timeout definition['config']['systemd_start_timeout'] if definition['config']['systemd_start_timeout']
    systemd_stop_timeout definition['config']['systemd_stop_timeout'] if definition['config']['systemd_stop_timeout']
    java_agents definition['config']['java_agents'] if definition['config']['java_agents']
    system_user system_username if system_username
    system_group system_group if system_group
  end

  Chef::Log.info "Defining GlassFish Domain #{domain_key} - secure_admin"

  remote_access = definition['config']['remote_access']

  # TODO: Merge glassfish_secure_admin into glassfish_domain?
  glassfish_secure_admin "#{domain_key}: secure_admin" do
    domain_name domain_key
    admin_port admin_port if admin_port
    username username if username
    password_file password_file if password_file
    secure secure if secure
    system_user system_username if system_username
    system_group system_group if system_group
    action ('true' == remote_access.to_s) ? :enable : :disable
  end

  if admin_port
    require 'net/https' if remote_access

    Chef::Log.info "Defining GlassFish Domain #{domain_key} - wait till up"

    ruby_block "block_until_glassfish_#{domain_key}_up" do
      block do

        def is_url_responding_with_code?(url, username, password, code)
          begin
            uri = URI(url)
            res = nil
            http = Net::HTTP.new(uri.hostname, uri.port)
            if url =~ /https\:/
              http.use_ssl = true
              http.verify_mode = OpenSSL::SSL::VERIFY_NONE
            end
            http.start do |http|
              request = Net::HTTP::Get.new(uri.request_uri)
              request.basic_auth username, password
              request['Accept'] = 'application/json'
              res = http.request(request)
            end
            return true if res.code.to_s == code.to_s
            puts "GlassFish not responding OK - #{res.code} to #{url}"
          rescue Exception => e
            puts "GlassFish error while accessing web interface at #{url}"
            puts e.message
            puts e.backtrace.join("\n")
            return url
          end
        end

        fail_count = 0
        loop do
          raise 'GlassFish failed to become operational' if fail_count > 50
          base_url = "http#{remote_access ? 's' : ''}://#{node['ipaddress']}:#{admin_port}"
          nodes_url = "#{base_url}/management/domain/nodes"
          applications_url = "#{base_url}/management/domain/applications"
          password = definition['config']['password']
          if is_url_responding_with_code?(nodes_url, username, password, 200) &&
            is_url_responding_with_code?(applications_url, username, password, 200) &&
            is_url_responding_with_code?(base_url, username, password, 200)
            sleep 1
            break
          end
          fail_count = fail_count + 1
          sleep 1
        end
      end
      action :create
    end
  end

  Chef::Log.info "Defining GlassFish Domain #{domain_key} - server instances"
  gf_sort(definition['instances'] || {}).each_pair do |key, config|
    glassfish_instance key do
      node_name config['node_name'] unless config['node_name'].nil?
      domain_name domain_key
      admin_port admin_port if admin_port
      username username if username
      password_file password_file if password_file
      secure secure if secure
      system_user system_username if system_username
      system_group system_group if system_group

      action :create
    end
  end

# Start Hopsworks Hack
case node["platform_family"]
when "rhel"
  kagent_config "glassfish-domain1" do
    action :systemd_reload
  end
end  
# Stop Hopsworks Hack
  
  Chef::Log.info "Defining GlassFish Domain #{domain_key} - caching properties"
  glassfish_property_cache "#{domain_key} Cache" do
    domain_name domain_key
    admin_port admin_port if admin_port
    username username if username
    password_file password_file if password_file
    secure secure if secure
    system_user system_username if system_username
    system_group system_group if system_group

    action :create
  end

  Chef::Log.info "Defining GlassFish Domain #{domain_key} - jvm_options"
  glassfish_jvm_options "JvmOptions #{domain_key}" do
    domain_name domain_key
    admin_port admin_port if admin_port
    username username if username
    password_file password_file if password_file
    secure secure if secure
    system_user system_username if system_username
    system_group system_group if system_group

    options domain.jvm_options
  end

  Chef::Log.info "Defining GlassFish Domain #{domain_key} - extra_libs"
  gf_sort(definition['extra_libraries'] || {}).values.each do |config|
    config = config.is_a?(Hash) ? config : {'url' => config}
    url = config['url']
    library_type = config['type'] || 'ext'
    requires_restart = config['requires_restart'].nil? ? false : config['requires_restart']
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
    end
  end

  Chef::Log.info "Defining GlassFish Domain #{domain_key} - threadpools"

  gf_sort(definition['threadpools'] || {}).each_pair do |key, config|
    glassfish_thread_pool key do
      domain_name domain_key
      admin_port admin_port if admin_port
      username username if username
      password_file password_file if password_file
      secure secure if secure
      system_user system_username if system_username
      system_group system_group if system_group

      maxthreadpoolsize config['maxthreadpoolsize'] if config['maxthreadpoolsize']
      minthreadpoolsize config['minthreadpoolsize'] if config['minthreadpoolsize']
      idletimeout config['idletimeout'] if config['idletimeout']
      maxqueuesize config['maxqueuesize'] if config['maxqueuesize']
    end
  end

  Chef::Log.info "Defining GlassFish Domain #{domain_key} - iiop listeners"
  gf_sort(definition['iiop_listeners'] || {}).each_pair do |key, config|
    glassfish_iiop_listener key do
      domain_name domain_key
      admin_port admin_port if admin_port
      username username if username
      password_file password_file if password_file
      secure secure if secure
      system_user system_username if system_username
      system_group system_group if system_group

      listeneraddress config['listeneraddress'] if config['listeneraddress']
      iiopport config['iiopport'] if config['iiopport']
      enabled config['enabled'] unless config['enabled'].nil?
      securityenabled config['securityenabled'] unless config['securityenabled'].nil?
      maxqueuesize config['maxqueuesize'] if config['maxqueuesize']
      properties config['properties'] if config['properties']
    end
  end

  Chef::Log.info "Defining GlassFish Domain #{domain_key} - context_services"
  gf_sort(definition['context_services'] || {}).each_pair do |key, config|
    glassfish_context_service key do
      domain_name domain_key
      admin_port admin_port if admin_port
      username username if username
      password_file password_file if password_file
      secure secure if secure
      system_user system_username if system_username
      system_group system_group if system_group
      enabled config['enabled'] unless config['enabled'].nil?
      contextinfoenabled config['contextinfoenabled'] unless config['contextinfoenabled'].nil?
      contextinfo config['contextinfo'] if config['contextinfo']
      description config['description'] if config['description']
    end
  end

  Chef::Log.info "Defining GlassFish Domain #{domain_key} - managed_thread_factories"
  gf_sort(definition['managed_thread_factories'] || {}).each_pair do |key, config|
    glassfish_managed_thread_factory key do
      domain_name domain_key
      admin_port admin_port if admin_port
      username username if username
      password_file password_file if password_file
      secure secure if secure
      system_user system_username if system_username
      system_group system_group if system_group

      enabled config['enabled'] unless config['enabled'].nil?
      contextinfoenabled config['contextinfoenabled'] unless config['contextinfoenabled'].nil?
      contextinfo config['contextinfo'] if config['contextinfo']
      description config['description'] if config['description']
      threadpriority config['threadpriority'] if config['threadpriority']
    end
  end

  Chef::Log.info "Defining GlassFish Domain #{domain_key} - managed_executor_services"

  gf_sort(definition['managed_executor_services'] || {}).each_pair do |key, config|
    glassfish_managed_executor_service key do
      domain_name domain_key
      admin_port admin_port if admin_port
      username username if username
      password_file password_file if password_file
      secure secure if secure
      system_user system_username if system_username
      system_group system_group if system_group

      enabled config['enabled'] unless config['enabled'].nil?
      contextinfoenabled config['contextinfoenabled'] unless config['contextinfoenabled'].nil?
      contextinfo config['contextinfo'] if config['contextinfo']
      description config['description'] if config['description']
      threadpriority config['threadpriority'] if config['threadpriority']
      corepoolsize config['corepoolsize'] if config['corepoolsize']
      hungafterseconds config['hungafterseconds'] if config['hungafterseconds']
      keepaliveseconds config['keepaliveseconds'] if config['keepaliveseconds']
      longrunningtasks config['longrunningtasks'] if config['longrunningtasks']
      maximumpoolsize config['maximumpoolsize'] if config['maximumpoolsize']
      taskqueuecapacity config['taskqueuecapacity'] if config['taskqueuecapacity']
      threadlifetimeseconds config['threadlifetimeseconds'] if config['threadlifetimeseconds']
    end
  end

  Chef::Log.info "Defining GlassFish Domain #{domain_key} - managed_scheduled_executor_services"
  gf_sort(definition['managed_scheduled_executor_services'] || {}).each_pair do |key, config|
    glassfish_managed_scheduled_executor_service key do
      domain_name domain_key
      admin_port admin_port if admin_port
      username username if username
      password_file password_file if password_file
      secure secure if secure
      system_user system_username if system_username
      system_group system_group if system_group

      enabled config['enabled'] unless config['enabled'].nil?
      contextinfoenabled config['contextinfoenabled'] unless config['contextinfoenabled'].nil?
      contextinfo config['contextinfo'] if config['contextinfo']
      description config['description'] if config['description']
      threadpriority config['threadpriority'] if config['threadpriority']
      corepoolsize config['corepoolsize'] if config['corepoolsize']
      hungafterseconds config['hungafterseconds'] if config['hungafterseconds']
      keepaliveseconds config['keepaliveseconds'] if config['keepaliveseconds']
      longrunningtasks config['longrunningtasks'] if config['longrunningtasks']
      threadlifetimeseconds config['threadlifetimeseconds'] if config['threadlifetimeseconds']
    end
  end

  Chef::Log.info "Defining GlassFish Domain #{domain_key} - properties"
  gf_sort(definition['properties'] || {}).each_pair do |key, value|
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

  ##
  ## Deploy all OSGi bundles prior to attempting to setup resources as they are likely to be the things
  ## that are provided by OSGi
  ##
  Chef::Log.info "Defining GlassFish Domain #{domain_key} - deployables"
  gf_sort(definition['deployables'] || {}).each_pair do |component_name, configuration|
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

  ##
  ## Deploy all resource archives prior to attempting to setup resources
  ##
  Chef::Log.info "Defining GlassFish Domain #{domain_key} - deployables"
  gf_sort(definition['deployables'] || {}).each_pair do |component_name, configuration|
    if configuration['type'] && configuration['type'].to_s == 'rar'
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
      gf_sort(configuration['web_env_entries'] || {}).each_pair do |key, value|
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
          value hash['value'].to_s unless hash['value'].nil?
          description hash['description'] if hash['description']
        end
      end
      if configuration['recipes'] && configuration['recipes']['after']
        gf_sort(configuration['recipes']['after']).each_pair do |recipe, config|
          include_recipe recipe
        end
      end
    end
  end

  Chef::Log.info "Defining GlassFish Domain #{domain_key} - realms"
  gf_sort(definition['realms'] || {}).each_pair do |key, configuration|
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

  Chef::Log.info "Defining GlassFish Domain #{domain_key} - jdbc_connection_pools"
  gf_sort(definition['jdbc_connection_pools'] || {}).each_pair do |key, configuration|
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
    gf_sort(configuration['resources'] || {}).each_pair do |resource_name, resource_configuration|
      Chef::Log.info "Defining GlassFish JDBC Resource #{resource_name}, config: #{resource_configuration}"

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

  Chef::Log.info "Defining GlassFish Domain #{domain_key} - resource_adapters"
  gf_sort(definition['resource_adapters'] || {}).each_pair do |resource_adapter_key, resource_configuration|
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
    gf_sort(resource_configuration['connection_pools'] || {}).each_pair do |pool_key, pool_configuration|
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
      gf_sort(pool_configuration['resources'] || {}).each_pair do |resource_name, resource_configuration|
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
    gf_sort(resource_configuration['admin_objects'] || {}).each_pair do |admin_object_key, admin_object_configuration|
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

  Chef::Log.info "Defining GlassFish Domain #{domain_key} - jms_destinations"
  gf_sort(definition['jms_destinations'] || {}).each_pair do |key, resource_config|
    glassfish_jms_destination key.to_s do
      domain_name domain_key
      admin_port admin_port if admin_port
      username username if username
      password_file password_file if password_file
      secure secure if secure
      system_user system_username if system_username
      system_group system_group if system_group
      desttype (resource_config['desttype'] || 'Queue')
    end
  end

  Chef::Log.info "Defining GlassFish Domain #{domain_key} - jms_resources"
  gf_sort(definition['jms_resources'] || {}).each_pair do |key, resource_config|
    glassfish_jms_resource key.to_s do
      domain_name domain_key
      admin_port admin_port if admin_port
      username username if username
      password_file password_file if password_file
      secure secure if secure
      system_user system_username if system_username
      system_group system_group if system_group
      target resource_config['target'] if resource_config['target']
      enabled resource_config['enabled'] if resource_config['enabled']
      description resource_config['description'] if resource_config['description']
      properties resource_config['properties'] if resource_config['properties']
      restype (resource_config['restype'] || 'javax.jms.Queue')
    end
  end

  Chef::Log.info "Defining GlassFish Domain #{domain_key} - custom_resources"
  gf_sort(definition['custom_resources'] || {}).each_pair do |key, value|
    hash = value.is_a?(Hash) ? value : {'value' => value}
    hash['restype'] = 'java.lang.Boolean' if hash['restype'].nil? && (hash['value'].is_a?(TrueClass) || hash['value'].is_a?(FalseClass))
    hash['restype'] = 'java.lang.Integer' if hash['restype'].nil? && hash['value'].is_a?(Fixnum)
    hash['restype'] = 'java.lang.Long' if hash['restype'].nil? && hash['value'].is_a?(Bignum)
    hash['restype'] = 'java.lang.Float' if hash['restype'].nil? && hash['value'].is_a?(Float)
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
      value hash['value'].to_s unless hash['value'].nil?
    end
  end

  Chef::Log.info "Defining GlassFish Domain #{domain_key} - javamail_resources"
  gf_sort(definition['javamail_resources'] || {}).each_pair do |key, javamail_configuration|
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

  Chef::Log.info "Defining GlassFish Domain #{domain_key} - deployables"
  gf_sort(definition['deployables'] || {}).each_pair do |component_name, configuration|
    if configuration['type'].nil? || (configuration['type'].to_s != 'osgi' && configuration['type'].to_s != 'rar')
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
        libraries configuration['libraries'] if configuration['libraries']
      end
      gf_sort(configuration['web_env_entries'] || {}).each_pair do |key, value|
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
          value hash['value'].to_s unless hash['value'].nil?
          description hash['description'] if hash['description']
        end
      end
      if configuration['recipes'] && configuration['recipes']['after']
        gf_sort(configuration['recipes']['after']).each_pair do |recipe, config|
          include_recipe recipe
        end
      end
    end
  end

  Chef::Log.info "Defining GlassFish Domain #{domain_key} - scanning existing applications"
  gf_scan_existing_resources(admin_port,
                             username,
                             password_file,
                             secure,
                             'list-applications') do |application_name|
    Chef::Log.info "Defining GlassFish Domain #{domain_key} - scanning existing application #{application_name}"
    unless (definition['deployables'] || {}).keys.include?(application_name)
      Chef::Log.info "Defining GlassFish Domain #{domain_key} - undeploying existing resource #{application_name}"
      glassfish_deployable application_name do
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
  end if gf_managed?(definition['deployables'])

  Chef::Log.info "Defining GlassFish Domain #{domain_key} - checking web-env entry for existing resources"
  gf_sort(definition['deployables'] || {}).each_pair do |component_name, configuration|
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
  end if gf_managed?(definition['deployables'])

  Chef::Log.info "Defining GlassFish Domain #{domain_key} - checking existing instances"
  gf_scan_existing_resources(admin_port,
                             username,
                             password_file,
                             secure,
                             'list-instances') do |existing|
    Chef::Log.info "Defining GlassFish Domain #{domain_key} - checking instances for #{existing}"
    unless definition['instances'] && definition['instances'][existing]
      Chef::Log.info "Defining GlassFish Domain #{domain_key} - removing instance #{existing}"
      glassfish_instance existing do
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
  end if gf_managed?(definition['instances'])

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
  end if gf_managed?(definition['resource_adapters'])

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

    jms_defined_resources = []
    gf_sort(definition['jms_resources'] || {}).each_pair do |key, resource_config|
      restype = resource_config['restype'] || 'javax.jms.Queue'
      jms_defined_resources << "#{key}-Connection-Pool" if ['javax.jms.ConnectionFactory','javax.jms.TopicConnectionFactory','javax.jms.QueueConnectionFactory'].include?(restype)
    end

    unless found || jms_defined_resources.include?(existing)
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
  end if gf_managed?(definition['resource_adapters'])

  Chef::Log.info "Defining GlassFish Domain #{domain_key} - checking existing resource connectors"
  gf_scan_existing_resources(admin_port, username, password_file, secure, 'list-connector-resources') do |existing|
    Chef::Log.info "Defining GlassFish Domain #{domain_key} - considering existing resource connector #{existing}"
    found = false
    gf_sort(definition['resource_adapters'] || {}).each_pair do |key, configuration|
      gf_sort(configuration['connection_pools'] || {}).each_pair do |pool_name, pool_configuration|
        if pool_configuration['resources'] && pool_configuration['resources'][existing]
          found = true
        end
      end
    end

    jms_defined_resources = []
    gf_sort(definition['jms_resources'] || {}).each_pair do |key, resource_config|
      restype = resource_config['restype'] || 'javax.jms.Queue'
      jms_defined_resources << key if ['javax.jms.ConnectionFactory','javax.jms.TopicConnectionFactory','javax.jms.QueueConnectionFactory'].include?(restype)
    end

    unless found || jms_defined_resources.include?(existing)
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
  end if gf_managed?(definition['resource_adapters'])

  Chef::Log.info "Defining GlassFish Domain #{domain_key} - checking existing admin objects"
  gf_scan_existing_resources(admin_port, username, password_file, secure, 'list-admin-objects') do |existing|
    Chef::Log.info "Defining GlassFish Domain #{domain_key} - considering existing admin object #{existing}"
    found = false
    gf_sort(definition['resource_adapters'] || {}).each_pair do |key, configuration|
      if configuration['admin_objects'] && configuration['admin_objects'][existing]
        found = true
      end
    end

    jms_defined_resources = []
    gf_sort(definition['jms_resources'] || {}).each_pair do |key, resource_config|
      restype = resource_config['restype'] || 'javax.jms.Queue'
      jms_defined_resources << key if ['javax.jms.Queue','javax.jms.Topic'].include?(restype)
    end

    unless found || jms_defined_resources.include?(existing)
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
  end if gf_managed?(definition['resource_adapters'])

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
  end if gf_managed?(definition['jdbc_connection_pools'])

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
  end if gf_managed?(definition['jdbc_connection_pools'])

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
  end if gf_managed?(definition['javamail_resources'])

  jmsra_defined_resources = []
  if definition['resource_adapters'] &&
    definition['resource_adapters']['jmsra']
    if definition['resource_adapters']['jmsra']['connection_pools']
      definition['resource_adapters']['jmsra']['connection_pools'].each_value do |pool|
        pool['resources'].keys.each { |k| jmsra_defined_resources << k } if pool['resources']
      end
    end
    if definition['resource_adapters']['jmsra']['admin_objects']
      definition['resource_adapters']['jmsra']['admin_objects'].keys.each { |k| jmsra_defined_resources << k }
    end
  end

  Chef::Log.info "Defining GlassFish Domain #{domain_key} - checking existing jms resources"
  gf_scan_existing_resources(admin_port, username, password_file, secure, 'list-jms-resources') do |existing|
    Chef::Log.info "Defining GlassFish Domain #{domain_key} - considering existing jms resource #{existing}"
    unless (definition['jms_resources'] && definition['jms_resources'][existing]) || jmsra_defined_resources.include?(existing)
      Chef::Log.info "Defining GlassFish Domain #{domain_key} - removing existing jms resource #{existing}"
      glassfish_jms_resource existing do
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
  end if gf_managed?(definition['jms_resources'])

  Chef::Log.info "Defining GlassFish Domain #{domain_key} - checking existing custom resources"
  gf_scan_existing_resources(admin_port, username, password_file, secure, 'list-custom-resources') do |existing|
    Chef::Log.info "Defining GlassFish Domain #{domain_key} - considering existing custom resource #{existing}"
    unless definition['custom_resources'] && !definition['custom_resources'][existing].nil?
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
  end if gf_managed?(definition['custom_resources'])

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
  end if gf_managed?(definition['resource_adapters'])

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
  end if gf_managed?(definition['realms'])

  Chef::Log.info "Defining GlassFish Domain #{domain_key} - checking existing iiop_listeners"
  gf_scan_existing_resources(admin_port, username, password_file, secure, 'list-iiop-listeners') do |existing|
    Chef::Log.info "Defining GlassFish Domain #{domain_key} - considering existing iiop_listeners #{existing}"
    unless definition['iiop_listeners'] && definition['iiop_listeners'][existing]
      Chef::Log.info "Defining GlassFish Domain #{domain_key} - removing existing iiop-listener #{existing}"
      glassfish_iiop_listener existing do
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
  end if gf_managed?(definition['iiop_listeners'])

  Chef::Log.info "Defining GlassFish Domain #{domain_key} - checking existing managed_scheduled_executor_services"
  gf_scan_existing_resources(admin_port, username, password_file, secure, 'list-managed-scheduled-executor-services') do |existing|
    Chef::Log.info "Defining GlassFish Domain #{domain_key} - considering existing managed_scheduled_executor_services #{existing}"
    default_context = 'concurrent/__defaultManagedScheduledExecutorService'
    unless definition['managed_scheduled_executor_services'] && definition['managed_scheduled_executor_services'][existing] || default_context == existing
      Chef::Log.info "Defining GlassFish Domain #{domain_key} - removing existing managed_scheduled_executor_services #{existing}"
      glassfish_managed_scheduled_executor_service existing do
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
  end if gf_managed?(definition['managed_scheduled_executor_services'])

  Chef::Log.info "Defining GlassFish Domain #{domain_key} - checking existing managed_executor_services"
  gf_scan_existing_resources(admin_port, username, password_file, secure, 'list-managed-executor-services') do |existing|
    Chef::Log.info "Defining GlassFish Domain #{domain_key} - considering existing managed_executor_services #{existing}"
    default_context = 'concurrent/__defaultManagedExecutorService'
    unless definition['managed_executor_services'] && definition['managed_executor_services'][existing] || default_context == existing
      Chef::Log.info "Defining GlassFish Domain #{domain_key} - removing existing managed_executor_services #{existing}"
      glassfish_managed_executor_service existing do
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
  end if gf_managed?(definition['managed_executor_services'])

  Chef::Log.info "Defining GlassFish Domain #{domain_key} - checking existing managed_thread_factories"
  gf_scan_existing_resources(admin_port, username, password_file, secure, 'list-managed-thread-factories') do |existing|
    Chef::Log.info "Defining GlassFish Domain #{domain_key} - considering existing managed_thread_factories #{existing}"
    default_context = 'concurrent/__defaultManagedThreadFactory'
    unless definition['managed_thread_factories'] && definition['managed_thread_factories'][existing] || default_context == existing
      Chef::Log.info "Defining GlassFish Domain #{domain_key} - removing existing managed_thread_factories #{existing}"
      glassfish_managed_thread_factory existing do
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
  end if gf_managed?(definition['managed_thread_factories'])

  Chef::Log.info "Defining GlassFish Domain #{domain_key} - checking existing context_services"
  gf_scan_existing_resources(admin_port, username, password_file, secure, 'list-context-services') do |existing|
    Chef::Log.info "Defining GlassFish Domain #{domain_key} - considering existing context_services #{existing}"
    default_context = 'concurrent/__defaultContextService'
    unless definition['context_services'] && definition['context_services'][existing] || default_context == existing
      Chef::Log.info "Defining GlassFish Domain #{domain_key} - removing existing context_services #{existing}"
      glassfish_context_service existing do
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
  end if gf_managed?(definition['context_services'])

  Chef::Log.info "Defining GlassFish Domain #{domain_key} - checking existing thread pools"
  gf_scan_existing_resources(admin_port, username, password_file, secure, 'list-threadpools') do |existing|
    Chef::Log.info "Defining GlassFish Domain #{domain_key} - considering existing thread-pools #{existing}"
    unless definition['thread-pools'] && definition['thread-pools'][existing]
      Chef::Log.info "Defining GlassFish Domain #{domain_key} - removing existing thread-pool #{existing}"
      glassfish_thread_pool existing do
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
  end if gf_managed?(definition['thread-pools'])

  Chef::Log.info "Defining GlassFish Domain #{domain_key} - removing cached properties"
  glassfish_property_cache "#{domain_key} Cache" do
    domain_name domain_key
    admin_port admin_port if admin_port
    username username if username
    password_file password_file if password_file
    secure secure if secure
    system_user system_username if system_username
    system_group system_group if system_group

    action :delete
  end

  Chef::Log.info "Defining GlassFish Domain #{domain_key} - complete"
  RealityForge::GlassFish.set_current_domain(node, nil)
end

gf_sort(node['glassfish']['domains']).each_pair do |domain_key, definition|
  RealityForge::GlassFish.set_current_domain(node, domain_key)
  if definition['recipes'] && definition['recipes']['after']
    gf_sort(definition['recipes']['after']).each_pair do |recipe, config|
      Chef::Log.info "Including domain 'after' recipe '#{recipe}' Priority: #{gf_priority(config)}"
      include_recipe recipe
    end
  end
  RealityForge::GlassFish.set_current_domain(node, nil)
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
