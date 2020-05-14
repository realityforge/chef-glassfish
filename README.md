# Description

[![Build Status](https://api.travis-ci.com/realityforge/chef-glassfish.svg?branch=master)](http://travis-ci.com/realityforge/chef-glassfish)

The glassfish cookbook installs and configures the GlassFish application server and the OpenMQ message broker bundled
with the GlassFish application server. The cookbook also defines resources to create and configure GlassFish
application domains and OpenMQ broker instances.

A sample project with a Vagrantfile that launches a glassfish instance is available in [chef-glassfish-example](https://github.com/realityforge/chef-glassfish-example) project.

# Requirements

## Platform:

* ubuntu
* debian
* windows

## Cookbooks:

* java
* authbind
* archive
* cutlery
* runit

# Attributes

* `node['glassfish']['user']` - GlassFish User: The user that GlassFish executes as. Defaults to `glassfish`.
* `node['glassfish']['group']` - GlassFish Admin Group: The group allowed to manage GlassFish domains. Defaults to `glassfish-admin`.
* `node['glassfish']['version']` - Version: The version of the GlassFish install package. Defaults to `4.0`.
* `node['glassfish']['variant']` - variant: The variant of the GlassFish install package. Usually payara or glassfish. Defaults to `glassfish`.
* `node['glassfish']['package_url']` - Package URL: The url to the GlassFish install package. Defaults to `nil`.
* `node['glassfish']['base_dir']` - GlassFish Base Directory: The base directory of the GlassFish install. Defaults to `/usr/local/glassfish` (Linux) or `C:\glassfish` (Windows).
* `node['glassfish']['install_dir']` - GlassFish Install Directory: The directory into which glassfish is actually installed. Defaults to `nil`.
* `node['glassfish']['remove_domains_dir_on_install']` - A flag determining whether we should remove the domains directory. Defaults to `true`.
* `node['glassfish']['domains_dir']` - GlassFish Domain Directory: The directory containing all the domain instance data and configuration. Defaults to `/srv/glassfish`.
* `node['glassfish']['domains']` - GlassFish Domain Definitions: A map of domain definitions that drive the instantiation of a domain. Defaults to `Mash.new`.
* `node['glassfish']['asadmin']['timeout']` - Asadmin Timeout: The timeout in seconds set for asadmin calls. Defaults to `150`.
* `node['openmq']['extra_libraries']` - Extract libraries for the OpenMQ Broker: A list of URLs to jars that are added to brokers classpath. Defaults to `Mash.new`.
* `node['openmq']['instances']` - GlassFish OpenMQ Broker Definitions: A map of broker definitions that drive the instantiation of a OpenMQ broker. Defaults to `Mash.new`.
* `node['openmq']['var_home']` - GlassFish OpenMQ Broker Directory: The directory containing all the broker instance data and configuration. Defaults to `/var/omq`.

# Recipes

* [glassfish::attribute_driven_domain](#glassfishattribute_driven_domain) - Configures 0 or more GlassFish domains using the glassfish/domains attribute.
* [glassfish::attribute_driven_mq](#glassfishattribute_driven_mq) - Configures 0 or more GlassFish OpenMQ brokers using the openmq/instances attribute.
* [glassfish::default](#glassfishdefault) - Downloads, and extracts the glassfish binaries, creates the glassfish user and group.
* [glassfish::search_driven_domain](#glassfishsearch_driven_domain) - Configures 0 or more GlassFish domains using search to generate the configuration.

## glassfish::attribute_driven_domain

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

## glassfish::attribute_driven_mq

Configures 0 or more GlassFish OpenMQ brokers using the openmq/instances attribute.

The `attribute_driven_mq` recipe interprets attributes on the node and defines the resources described in the attributes.

## glassfish::default

Downloads, and extracts the glassfish binaries, creates the glassfish user and group.

Does not create any Application Server or Message Broker instances. This recipe is not
typically included directly but is included transitively through either <code>glassfish::attribute_driven_domain</code>
or <code>glassfish::attribute_driven_mq</code>.

## glassfish::search_driven_domain

Configures 0 or more GlassFish domains using search to generate the configuration.

# Resources

* [glassfish_admin_object](#glassfish_admin_object)
* [glassfish_asadmin](#glassfish_asadmin) - Asadmin is the command line application used to manage a GlassFish application server.
* [glassfish_auth_realm](#glassfish_auth_realm)
* [glassfish_connector_connection_pool](#glassfish_connector_connection_pool)
* [glassfish_connector_resource](#glassfish_connector_resource)
* [glassfish_context_service](#glassfish_context_service)
* [glassfish_custom_resource](#glassfish_custom_resource)
* [glassfish_deployable](#glassfish_deployable)
* [glassfish_domain](#glassfish_domain) - Creates a GlassFish application domain, creates an OS-level service and starts the service.
* [glassfish_iiop_listener](#glassfish_iiop_listener)
* [glassfish_instance](#glassfish_instance) - Creates a GlassFish server instance in the domain configuration.
* [glassfish_javamail_resource](#glassfish_javamail_resource)
* [glassfish_jdbc_connection_pool](#glassfish_jdbc_connection_pool)
* [glassfish_jdbc_resource](#glassfish_jdbc_resource)
* [glassfish_jms_destination](#glassfish_jms_destination)
* [glassfish_jms_resource](#glassfish_jms_resource)
* [glassfish_jvm_options](#glassfish_jvm_options)
* [glassfish_library](#glassfish_library)
* [glassfish_managed_executor_service](#glassfish_managed_executor_service)
* [glassfish_managed_scheduled_executor_service](#glassfish_managed_scheduled_executor_service)
* [glassfish_managed_thread_factory](#glassfish_managed_thread_factory)
* [glassfish_mq](#glassfish_mq) - Creates an OpenMQ message broker instance, creates an OS-level service and starts the service.
* [glassfish_mq_destination](#glassfish_mq_destination) - Creates or deletes a queue or a topic in an OpenMQ message broker instance.
* [glassfish_mq_ensure_running](#glassfish_mq_ensure_running) - Ensures that a OpenMQ message broker instance has had a chance to finish starting before proceeding.
* [glassfish_property](#glassfish_property)
* [glassfish_property_cache](#glassfish_property_cache)
* [glassfish_resource_adapter](#glassfish_resource_adapter)
* [glassfish_secure_admin](#glassfish_secure_admin) - Enable or disable secure admin flag on the GlassFish server which enables/disables remote administration.
* [glassfish_thread_pool](#glassfish_thread_pool)
* [glassfish_web_env_entry](#glassfish_web_env_entry) - Set a value that can be retrieved as a `web env entry` in a particular web application.

## glassfish_admin_object

### Actions

- create:  Default action.
- delete:

### Attribute Parameters

- jndi_name:
- raname:
- restype:
- enabled:  Defaults to <code>true</code>.
- target:  Defaults to <code>"server"</code>.
- classname:  Defaults to <code>nil</code>.
- description:  Defaults to <code>nil</code>.
- properties:  Defaults to <code>{}</code>.
- domain_name: The name of the domain.
- terse: Use terse output from the underlying asadmin. Defaults to <code>false</code>.
- echo: If true, echo commands supplied to asadmin. Defaults to <code>true</code>.
- username: The username to use when communicating with the domain. Defaults to <code>nil</code>.
- password_file: The file in which the password must be stored assigned to appropriate key. Defaults to <code>nil</code>.
- secure: If true use SSL when communicating with the domain for administration. Defaults to <code>false</code>.
- admin_port: The port on which the web management console is bound. Defaults to <code>4848</code>.
- system_user: The user that the domain executes as. Defaults to `node['glassfish']['user']` if unset. Defaults to <code>nil</code>.
- system_group: The group that the domain executes as. Defaults to `node['glassfish']['group']` if unset. Defaults to <code>nil</code>.

## glassfish_asadmin

Asadmin is the command line application used to manage a GlassFish application server. Typically this resource is
used when there is not yet a resource defined in this cookbook for executing an underlying command on the server.

### Actions

- run: Execute the command. Default action.

### Attribute Parameters

- command: The command to execute.
- returns: A return code or an array of return codes that are considered successful completions. Defaults to <code>0</code>.
- domain_name: The name of the domain.
- terse: Use terse output from the underlying asadmin. Defaults to <code>false</code>.
- echo: If true, echo commands supplied to asadmin. Defaults to <code>true</code>.
- username: The username to use when communicating with the domain. Defaults to <code>nil</code>.
- password_file: The file in which the password must be stored assigned to appropriate key. Defaults to <code>nil</code>.
- secure: If true use SSL when communicating with the domain for administration. Defaults to <code>false</code>.
- admin_port: The port on which the web management console is bound. Defaults to <code>4848</code>.
- system_user: The user that the domain executes as. Defaults to `node['glassfish']['user']` if unset. Defaults to <code>nil</code>.
- system_group: The group that the domain executes as. Defaults to `node['glassfish']['group']` if unset. Defaults to <code>nil</code>.

### Examples

    # List all the domains on the server
    glassfish_asadmin "list-domains" do
       domain_name 'my_domain'
    end

## glassfish_auth_realm

### Actions

- create:  Default action.
- delete:

### Attribute Parameters

- realm_name:
- target:  Defaults to <code>"server"</code>.
- classname:
- jaas_context:  Defaults to <code>nil</code>.
- assign_groups:  Defaults to <code>nil</code>.
- properties:  Defaults to <code>{}</code>.
- domain_name: The name of the domain.
- terse: Use terse output from the underlying asadmin. Defaults to <code>false</code>.
- echo: If true, echo commands supplied to asadmin. Defaults to <code>true</code>.
- username: The username to use when communicating with the domain. Defaults to <code>nil</code>.
- password_file: The file in which the password must be stored assigned to appropriate key. Defaults to <code>nil</code>.
- secure: If true use SSL when communicating with the domain for administration. Defaults to <code>false</code>.
- admin_port: The port on which the web management console is bound. Defaults to <code>4848</code>.
- system_user: The user that the domain executes as. Defaults to `node['glassfish']['user']` if unset. Defaults to <code>nil</code>.
- system_group: The group that the domain executes as. Defaults to `node['glassfish']['group']` if unset. Defaults to <code>nil</code>.

## glassfish_connector_connection_pool

### Actions

- create:  Default action.
- delete:

### Attribute Parameters

- pool_name:
- description:  Defaults to <code>nil</code>.
- raname:
- connectiondefinition:
- steadypoolsize:  Defaults to <code>nil</code>.
- maxpoolsize:  Defaults to <code>nil</code>.
- maxwait:  Defaults to <code>nil</code>.
- poolresize:  Defaults to <code>nil</code>.
- idletimeout:  Defaults to <code>nil</code>.
- leaktimeout:  Defaults to <code>nil</code>.
- validateatmostonceperiod:  Defaults to <code>nil</code>.
- maxconnectionusagecount:  Defaults to <code>nil</code>.
- creationretryattempts:  Defaults to <code>nil</code>.
- creationretryinterval:  Defaults to <code>nil</code>.
- isconnectvalidatereq:  Defaults to <code>nil</code>.
- failconnection:  Defaults to <code>nil</code>.
- leakreclaim:  Defaults to <code>nil</code>.
- lazyconnectionenlistment:  Defaults to <code>nil</code>.
- lazyconnectionassociation:  Defaults to <code>nil</code>.
- associatewiththread:  Defaults to <code>nil</code>.
- matchconnections:  Defaults to <code>nil</code>.
- ping:  Defaults to <code>nil</code>.
- pooling:  Defaults to <code>nil</code>.
- properties:  Defaults to <code>{}</code>.
- transactionsupport:
- domain_name: The name of the domain.
- terse: Use terse output from the underlying asadmin. Defaults to <code>false</code>.
- echo: If true, echo commands supplied to asadmin. Defaults to <code>true</code>.
- username: The username to use when communicating with the domain. Defaults to <code>nil</code>.
- password_file: The file in which the password must be stored assigned to appropriate key. Defaults to <code>nil</code>.
- secure: If true use SSL when communicating with the domain for administration. Defaults to <code>false</code>.
- admin_port: The port on which the web management console is bound. Defaults to <code>4848</code>.
- system_user: The user that the domain executes as. Defaults to `node['glassfish']['user']` if unset. Defaults to <code>nil</code>.
- system_group: The group that the domain executes as. Defaults to `node['glassfish']['group']` if unset. Defaults to <code>nil</code>.

## glassfish_connector_resource

### Actions

- create:  Default action.
- delete:

### Attribute Parameters

- resource_name:
- poolname:
- enabled:  Defaults to <code>true</code>.
- target:  Defaults to <code>"server"</code>.
- objecttype:  Defaults to <code>nil</code>.
- description:  Defaults to <code>nil</code>.
- properties:  Defaults to <code>{}</code>.
- domain_name: The name of the domain.
- terse: Use terse output from the underlying asadmin. Defaults to <code>false</code>.
- echo: If true, echo commands supplied to asadmin. Defaults to <code>true</code>.
- username: The username to use when communicating with the domain. Defaults to <code>nil</code>.
- password_file: The file in which the password must be stored assigned to appropriate key. Defaults to <code>nil</code>.
- secure: If true use SSL when communicating with the domain for administration. Defaults to <code>false</code>.
- admin_port: The port on which the web management console is bound. Defaults to <code>4848</code>.
- system_user: The user that the domain executes as. Defaults to `node['glassfish']['user']` if unset. Defaults to <code>nil</code>.
- system_group: The group that the domain executes as. Defaults to `node['glassfish']['group']` if unset. Defaults to <code>nil</code>.

## glassfish_context_service

### Actions

- create:  Default action.
- delete:

### Attribute Parameters

- jndi_name:
- target:  Defaults to <code>"server"</code>.
- enabled: Determines whether container contexts are propagated to threads. If set to true, the contexts specified in the --contextinfo option are propagated. If set to false, no contexts are propagated and the --contextinfo option is ignored. Defaults to <code>true</code>.
- contextinfoenabled:  Defaults to <code>true</code>.
- contextinfo: Descriptive details about the resource. Defaults to <code>"Classloader,JNDI,Security,WorkArea"</code>.
- description:
- domain_name: The name of the domain.
- terse: Use terse output from the underlying asadmin. Defaults to <code>false</code>.
- echo: If true, echo commands supplied to asadmin. Defaults to <code>true</code>.
- username: The username to use when communicating with the domain. Defaults to <code>nil</code>.
- password_file: The file in which the password must be stored assigned to appropriate key. Defaults to <code>nil</code>.
- secure: If true use SSL when communicating with the domain for administration. Defaults to <code>false</code>.
- admin_port: The port on which the web management console is bound. Defaults to <code>4848</code>.
- system_user: The user that the domain executes as. Defaults to `node['glassfish']['user']` if unset. Defaults to <code>nil</code>.
- system_group: The group that the domain executes as. Defaults to `node['glassfish']['group']` if unset. Defaults to <code>nil</code>.

## glassfish_custom_resource

### Actions

- create:  Default action.
- delete:

### Attribute Parameters

- jndi_name:
- target:  Defaults to <code>"server"</code>.
- restype:  Defaults to <code>"java.lang.String"</code>.
- factoryclass:  Defaults to <code>"org.glassfish.resources.custom.factory.PrimitivesAndStringFactory"</code>.
- enabled:  Defaults to <code>true</code>.
- description:  Defaults to <code>nil</code>.
- properties:  Defaults to <code>{}</code>.
- value:  Defaults to <code>nil</code>.
- domain_name: The name of the domain.
- terse: Use terse output from the underlying asadmin. Defaults to <code>false</code>.
- echo: If true, echo commands supplied to asadmin. Defaults to <code>true</code>.
- username: The username to use when communicating with the domain. Defaults to <code>nil</code>.
- password_file: The file in which the password must be stored assigned to appropriate key. Defaults to <code>nil</code>.
- secure: If true use SSL when communicating with the domain for administration. Defaults to <code>false</code>.
- admin_port: The port on which the web management console is bound. Defaults to <code>4848</code>.
- system_user: The user that the domain executes as. Defaults to `node['glassfish']['user']` if unset. Defaults to <code>nil</code>.
- system_group: The group that the domain executes as. Defaults to `node['glassfish']['group']` if unset. Defaults to <code>nil</code>.

## glassfish_deployable

### Actions

- deploy:  Default action.
- disable:
- enable:
- undeploy:

### Attribute Parameters

- component_name:
- version:  Defaults to <code>nil</code>.
- target:  Defaults to <code>"server"</code>.
- url:  Defaults to <code>nil</code>.
- enabled:  Defaults to <code>true</code>.
- type:  Defaults to <code>nil</code>.
- context_root:  Defaults to <code>nil</code>.
- virtual_servers:  Defaults to <code>[]</code>.
- generate_rmi_stubs:  Defaults to <code>false</code>.
- availability_enabled:  Defaults to <code>false</code>.
- lb_enabled:  Defaults to <code>true</code>.
- keep_state:  Defaults to <code>false</code>.
- verify:  Defaults to <code>false</code>.
- precompile_jsp:  Defaults to <code>true</code>.
- async_replication:  Defaults to <code>true</code>.
- properties:  Defaults to <code>{}</code>.
- descriptors:  Defaults to <code>{}</code>.
- libraries: Array of JAR file names deployed as applibs which are used by this deployable. Defaults to <code>[]</code>.
- domain_name: The name of the domain.
- terse: Use terse output from the underlying asadmin. Defaults to <code>false</code>.
- echo: If true, echo commands supplied to asadmin. Defaults to <code>true</code>.
- username: The username to use when communicating with the domain. Defaults to <code>nil</code>.
- password_file: The file in which the password must be stored assigned to appropriate key. Defaults to <code>nil</code>.
- secure: If true use SSL when communicating with the domain for administration. Defaults to <code>false</code>.
- admin_port: The port on which the web management console is bound. Defaults to <code>4848</code>.
- system_user: The user that the domain executes as. Defaults to `node['glassfish']['user']` if unset. Defaults to <code>nil</code>.
- system_group: The group that the domain executes as. Defaults to `node['glassfish']['group']` if unset. Defaults to <code>nil</code>.

## glassfish_domain

Creates a GlassFish application domain, creates an OS-level service and starts the service.

### Actions

- create: Create the domain, enable and start the associated service. Default action.
- destroy: Stop the associated service and delete the domain directory and associated artifacts.

### Attribute Parameters

- min_memory:  Defaults to <code>512</code>.
- max_memory: The amount of heap memory to allocate to the domain in MiB. Defaults to <code>512</code>.
- max_perm_size: The amount of perm gen memory to allocate to the domain in MiB. Defaults to <code>96</code>.
- max_stack_size: The amount of stack memory to allocate to the domain in KiB. Defaults to <code>350</code>.
- port: The port on which the HTTP service will bind. Defaults to <code>8080</code>.
- admin_port: The port on which the web management console is bound. Defaults to <code>4848</code>.
- extra_jvm_options: An array of extra arguments to pass the JVM. Defaults to <code>[]</code>.
- java_agents: An array of javaagent arguments to pass the JVM. Defaults to <code>[]</code>.
- env_variables: A hash of environment variables set when running the domain. Defaults to <code>{}</code>.
- portbase: Portbase from which port and admin_port are automatically calculated. Warning: This can't be used together with admin_port.
- systemd_enabled: is a boolean value to use systemd or not. Defaults to <code>false</code>.
- systemd_start_timeout: is an integer value which sets the service start timeout in seconds. Defaults to <code>90</code>.
- systemd_stop_timeout: is an integer value which sets the service stop timeout in seconds. Defaults to <code>90</code>.
- domain_name: The name of the domain.
- terse: Use terse output from the underlying asadmin. Defaults to <code>false</code>.
- echo: If true, echo commands supplied to asadmin. Defaults to <code>true</code>.
- username: The username to use when communicating with the domain. Defaults to <code>nil</code>.
- master_password: Password used to access the keystore. Defaults to password if unset. Defaults to <code>nil</code>.
- password: Password to use when communicating with the domain. Must be set if username is set. Defaults to <code>nil</code>.
- password_file: The file in which the password is saved. Should be set if username is set. Defaults to <code>nil</code>.
- secure: If true use SSL when communicating with the domain for administration. Defaults to <code>false</code>.
- logging_properties: A hash of properties that will be merged into logging.properties. Use this to send logs to syslog or graylog. Defaults to <code>{}</code>.
- realm_types: A map of names to realm implementation classes that is merged into the default realm types. Defaults to <code>{}</code>.
- system_user: The user that the domain executes as. Defaults to `node['glassfish']['user']` if unset. Defaults to <code>nil</code>.
- system_group: The group that the domain executes as. Defaults to `node['glassfish']['group']` if unset. Defaults to <code>nil</code>.
- certificate_cn: The common name that should be used when generating the self-signed ssl certificate for the domain. Default to <code>nil</code>

### Examples

    # Create a basic domain that logs to a central graylog server
    glassfish_domain "my_domain" do
      port 80
      admin_port 8103
      extra_libraries ['http://central.maven.org/maven2/org/realityforge/gelf4j/gelf4j/1.10/gelf4j-1.10-all.jar']
      logging_properties {
        "handlers" => "java.util.logging.ConsoleHandler, gelf4j.logging.GelfHandler",
        ".level" => "INFO",
        "java.util.logging.ConsoleHandler.level" => "INFO",
        "gelf4j.logging.GelfHandler.level" => "ALL",
        "gelf4j.logging.GelfHandler.host" => 'graylog.example.org',
        "gelf4j.logging.GelfHandler.defaultFields" => '{"environment": "' + node.chef_environment + '", "facility": "MyDomain"}'
      }
    end

## glassfish_iiop_listener

### Actions

- create:  Default action.
- delete:

### Attribute Parameters

- iioplistener_id:
- target:  Defaults to <code>"server"</code>.
- listeneraddress: Either the IP address or the hostname (resolvable by DNS).
- iiopport: The IIOP port number. Defaults to <code>1072</code>.
- securityenabled: If set to true, the IIOP listener runs SSL. You can turn SSL2 or SSL3 ON or OFF and set ciphers using an SSL element. The security setting globally enables or disables SSL by making certificates available to the server instance. Defaults to <code>false</code>.
- enabled: If set to true, the IIOP listener is enabled at runtime. Defaults to <code>true</code>.
- properties: Optional attribute name/value pairs for configuring the IIOP listener. Defaults to <code>{}</code>.
- domain_name: The name of the domain.
- terse: Use terse output from the underlying asadmin. Defaults to <code>false</code>.
- echo: If true, echo commands supplied to asadmin. Defaults to <code>true</code>.
- username: The username to use when communicating with the domain. Defaults to <code>nil</code>.
- password_file: The file in which the password must be stored assigned to appropriate key. Defaults to <code>nil</code>.
- secure: If true use SSL when communicating with the domain for administration. Defaults to <code>false</code>.
- admin_port: The port on which the web management console is bound. Defaults to <code>4848</code>.
- system_user: The user that the domain executes as. Defaults to `node['glassfish']['user']` if unset. Defaults to <code>nil</code>.
- system_group: The group that the domain executes as. Defaults to `node['glassfish']['group']` if unset. Defaults to <code>nil</code>.

## glassfish_instance

Creates a GlassFish server instance in the domain configuration.

### Actions

- create: Create the instance and start it.. Default action.
- delete: Stop the instance if running and remove it from the config.

### Attribute Parameters

- instance_name:
- node_name:
- config_name:
- lbenabled:
- portbase:
- checkports:
- systemproperties:  Defaults to <code>{}</code>.
- domain_name: The name of the domain.
- terse: Use terse output from the underlying asadmin. Defaults to <code>false</code>.
- echo: If true, echo commands supplied to asadmin. Defaults to <code>true</code>.
- username: The username to use when communicating with the domain. Defaults to <code>nil</code>.
- password_file: The file in which the password must be stored assigned to appropriate key. Defaults to <code>nil</code>.
- secure: If true use SSL when communicating with the domain for administration. Defaults to <code>false</code>.
- admin_port: The port on which the web management console is bound. Defaults to <code>4848</code>.
- system_user: The user that the domain executes as. Defaults to `node['glassfish']['user']` if unset. Defaults to <code>nil</code>.
- system_group: The group that the domain executes as. Defaults to `node['glassfish']['group']` if unset. Defaults to <code>nil</code>.

### Examples

    # Create a standalone Glassfish instance
    glassfish_instance "Myserver" do
      node_name 'localhost-domain1'
      lbenabled false
    end

## glassfish_javamail_resource

### Actions

- create:  Default action.
- delete:

### Attribute Parameters

- jndi_name:
- target:  Defaults to <code>"server"</code>.
- mailhost:
- mailuser:
- fromaddress:
- storeprotocol:
- storeprotocolclass:
- transprotocol:
- transprotocolclass:
- debug:  Defaults to <code>nil</code>.
- enabled:  Defaults to <code>true</code>.
- description:  Defaults to <code>nil</code>.
- properties:  Defaults to <code>{}</code>.
- domain_name: The name of the domain.
- terse: Use terse output from the underlying asadmin. Defaults to <code>false</code>.
- echo: If true, echo commands supplied to asadmin. Defaults to <code>true</code>.
- username: The username to use when communicating with the domain. Defaults to <code>nil</code>.
- password_file: The file in which the password must be stored assigned to appropriate key. Defaults to <code>nil</code>.
- secure: If true use SSL when communicating with the domain for administration. Defaults to <code>false</code>.
- admin_port: The port on which the web management console is bound. Defaults to <code>4848</code>.
- system_user: The user that the domain executes as. Defaults to `node['glassfish']['user']` if unset. Defaults to <code>nil</code>.
- system_group: The group that the domain executes as. Defaults to `node['glassfish']['group']` if unset. Defaults to <code>nil</code>.

## glassfish_jdbc_connection_pool

### Actions

- create:  Default action.
- delete:

### Attribute Parameters

- pool_name:
- datasourceclassname:  Defaults to <code>""</code>.
- initsql:  Defaults to <code>""</code>.
- sqltracelisteners:  Defaults to <code>""</code>.
- driverclassname:  Defaults to <code>""</code>.
- validationclassname:  Defaults to <code>""</code>.
- validationtable:  Defaults to <code>""</code>.
- steadypoolsize:  Defaults to <code>8</code>.
- maxpoolsize:  Defaults to <code>32</code>.
- maxwait:  Defaults to <code>60000</code>.
- poolresize:  Defaults to <code>2</code>.
- idletimeout:  Defaults to <code>300</code>.
- validateatmostonceperiod:  Defaults to <code>0</code>.
- leaktimeout:  Defaults to <code>0</code>.
- statementleaktimeout:  Defaults to <code>0</code>.
- creationretryattempts:  Defaults to <code>0</code>.
- creationretryinterval:  Defaults to <code>10</code>.
- statementtimeout:  Defaults to <code>-1</code>.
- maxconnectionusagecount:  Defaults to <code>0</code>.
- statementcachesize:  Defaults to <code>0</code>.
- isisolationguaranteed:  Defaults to <code>true</code>.
- isconnectvalidatereq:  Defaults to <code>true</code>.
- failconnection:  Defaults to <code>false</code>.
- allownoncomponentcallers:  Defaults to <code>false</code>.
- nontransactionalconnections:  Defaults to <code>false</code>.
- statmentleakreclaim:  Defaults to <code>false</code>.
- leakreclaim:  Defaults to <code>false</code>.
- lazyconnectionenlistment:  Defaults to <code>false</code>.
- lazyconnectionassociation:  Defaults to <code>false</code>.
- associatewiththread:  Defaults to <code>false</code>.
- matchconnections:  Defaults to <code>false</code>.
- ping:  Defaults to <code>true</code>.
- pooling:  Defaults to <code>true</code>.
- wrapjdbcobjects:  Defaults to <code>true</code>.
- description:  Defaults to <code>nil</code>.
- properties:  Defaults to <code>{}</code>.
- restype:  Defaults to <code>nil</code>.
- isolationlevel:
- validationmethod:
- domain_name: The name of the domain.
- terse: Use terse output from the underlying asadmin. Defaults to <code>false</code>.
- echo: If true, echo commands supplied to asadmin. Defaults to <code>true</code>.
- username: The username to use when communicating with the domain. Defaults to <code>nil</code>.
- password_file: The file in which the password must be stored assigned to appropriate key. Defaults to <code>nil</code>.
- secure: If true use SSL when communicating with the domain for administration. Defaults to <code>false</code>.
- admin_port: The port on which the web management console is bound. Defaults to <code>4848</code>.
- system_user: The user that the domain executes as. Defaults to `node['glassfish']['user']` if unset. Defaults to <code>nil</code>.
- system_group: The group that the domain executes as. Defaults to `node['glassfish']['group']` if unset. Defaults to <code>nil</code>.

## glassfish_jdbc_resource

### Actions

- create:  Default action.
- delete:

### Attribute Parameters

- resource_name:
- connectionpoolid:
- enabled:  Defaults to <code>true</code>.
- target:  Defaults to <code>"server"</code>.
- description:  Defaults to <code>nil</code>.
- properties:  Defaults to <code>{}</code>.
- domain_name: The name of the domain.
- terse: Use terse output from the underlying asadmin. Defaults to <code>false</code>.
- echo: If true, echo commands supplied to asadmin. Defaults to <code>true</code>.
- username: The username to use when communicating with the domain. Defaults to <code>nil</code>.
- password_file: The file in which the password must be stored assigned to appropriate key. Defaults to <code>nil</code>.
- secure: If true use SSL when communicating with the domain for administration. Defaults to <code>false</code>.
- admin_port: The port on which the web management console is bound. Defaults to <code>4848</code>.
- system_user: The user that the domain executes as. Defaults to `node['glassfish']['user']` if unset. Defaults to <code>nil</code>.
- system_group: The group that the domain executes as. Defaults to `node['glassfish']['group']` if unset. Defaults to <code>nil</code>.

## glassfish_jms_destination

### Actions

- create:  Default action.
- delete:

### Attribute Parameters

- name:
- desttype:  Defaults to <code>"queue"</code>.
- domain_name: The name of the domain.
- terse: Use terse output from the underlying asadmin. Defaults to <code>false</code>.
- echo: If true, echo commands supplied to asadmin. Defaults to <code>true</code>.
- username: The username to use when communicating with the domain. Defaults to <code>nil</code>.
- password_file: The file in which the password must be stored assigned to appropriate key. Defaults to <code>nil</code>.
- secure: If true use SSL when communicating with the domain for administration. Defaults to <code>false</code>.
- admin_port: The port on which the web management console is bound. Defaults to <code>4848</code>.
- system_user: The user that the domain executes as. Defaults to `node['glassfish']['user']` if unset. Defaults to <code>nil</code>.
- system_group: The group that the domain executes as. Defaults to `node['glassfish']['group']` if unset. Defaults to <code>nil</code>.

## glassfish_jms_resource

### Actions

- create:  Default action.
- delete:

### Attribute Parameters

- name:
- target:  Defaults to <code>"server"</code>.
- restype:  Defaults to <code>"javax.jms.Queue"</code>.
- enabled:  Defaults to <code>true</code>.
- description:  Defaults to <code>nil</code>.
- properties:  Defaults to <code>{}</code>.
- domain_name: The name of the domain.
- terse: Use terse output from the underlying asadmin. Defaults to <code>false</code>.
- echo: If true, echo commands supplied to asadmin. Defaults to <code>true</code>.
- username: The username to use when communicating with the domain. Defaults to <code>nil</code>.
- password_file: The file in which the password must be stored assigned to appropriate key. Defaults to <code>nil</code>.
- secure: If true use SSL when communicating with the domain for administration. Defaults to <code>false</code>.
- admin_port: The port on which the web management console is bound. Defaults to <code>4848</code>.
- system_user: The user that the domain executes as. Defaults to `node['glassfish']['user']` if unset. Defaults to <code>nil</code>.
- system_group: The group that the domain executes as. Defaults to `node['glassfish']['group']` if unset. Defaults to <code>nil</code>.

## glassfish_jvm_options

### Actions

- set:  Default action.

### Attribute Parameters

- target:  Defaults to <code>"server"</code>.
- options:  Defaults to <code>[]</code>.
- domain_name: The name of the domain.
- terse: Use terse output from the underlying asadmin. Defaults to <code>false</code>.
- echo: If true, echo commands supplied to asadmin. Defaults to <code>true</code>.
- username: The username to use when communicating with the domain. Defaults to <code>nil</code>.
- password_file: The file in which the password must be stored assigned to appropriate key. Defaults to <code>nil</code>.
- secure: If true use SSL when communicating with the domain for administration. Defaults to <code>false</code>.
- admin_port: The port on which the web management console is bound. Defaults to <code>4848</code>.
- system_user: The user that the domain executes as. Defaults to `node['glassfish']['user']` if unset. Defaults to <code>nil</code>.
- system_group: The group that the domain executes as. Defaults to `node['glassfish']['group']` if unset. Defaults to <code>nil</code>.

## glassfish_library

### Actions

- add:  Default action.
- remove:

### Attribute Parameters

- url:
- library_type:  Defaults to <code>"common"</code>.
- upload:  Defaults to <code>true</code>.
- requires_restart:  Defaults to <code>false</code>.
- domain_name: The name of the domain.
- terse: Use terse output from the underlying asadmin. Defaults to <code>false</code>.
- echo: If true, echo commands supplied to asadmin. Defaults to <code>true</code>.
- username: The username to use when communicating with the domain. Defaults to <code>nil</code>.
- password_file: The file in which the password must be stored assigned to appropriate key. Defaults to <code>nil</code>.
- secure: If true use SSL when communicating with the domain for administration. Defaults to <code>false</code>.
- admin_port: The port on which the web management console is bound. Defaults to <code>4848</code>.
- system_user: The user that the domain executes as. Defaults to `node['glassfish']['user']` if unset. Defaults to <code>nil</code>.
- system_group: The group that the domain executes as. Defaults to `node['glassfish']['group']` if unset. Defaults to <code>nil</code>.

## glassfish_managed_executor_service

### Actions

- create:  Default action.
- delete:

### Attribute Parameters

- jndi_name:
- target:  Defaults to <code>"server"</code>.
- enabled: Determines whether container contexts are propagated to threads. If set to true, the contexts specified in the --contextinfo option are propagated. If set to false, no contexts are propagated and the --contextinfo option is ignored. Defaults to <code>true</code>.
- contextinfoenabled:  Defaults to <code>true</code>.
- contextinfo: Descriptive details about the resource. Defaults to <code>"Classloader,JNDI,Security,WorkArea"</code>.
- description:
- threadpriority: Specifies the priority to assign to created threads. Defaults to <code>5</code>.
- longrunningtasks: Specifies whether the resource should be used for long-running tasks. If set to true, long-running tasks are not reported as stuck. Defaults to <code>false</code>.
- hungafterseconds: Specifies the number of seconds that a task can execute before it is considered unresponsive. If the value is 0 tasks are never considered unresponsive. Defaults to <code>0</code>.
- corepoolsize: Specifies the number of threads to keep in a thread pool, even if they are idle. Defaults to <code>0</code>.
- maximumpoolsize: Specifies the maximum number of threads that a thread pool can contain. Defaults to <code>2147483647</code>.
- keepaliveseconds: Specifies the number of seconds that threads can remain idle when the number of threads is greater than corepoolsize. Defaults to <code>60</code>.
- threadlifetimeseconds: Specifies the number of seconds that threads can remain in a thread pool before being purged, regardless of whether the number of threads is greater than corepoolsize or whether the threads are idle. The value of 0 means that threads are never purged. Defaults to <code>0</code>.
- taskqueuecapacity: Specifies the number of submitted tasks that can be stored in the task queue awaiting execution. Defaults to <code>2147483647</code>.
- domain_name: The name of the domain.
- terse: Use terse output from the underlying asadmin. Defaults to <code>false</code>.
- echo: If true, echo commands supplied to asadmin. Defaults to <code>true</code>.
- username: The username to use when communicating with the domain. Defaults to <code>nil</code>.
- password_file: The file in which the password must be stored assigned to appropriate key. Defaults to <code>nil</code>.
- secure: If true use SSL when communicating with the domain for administration. Defaults to <code>false</code>.
- admin_port: The port on which the web management console is bound. Defaults to <code>4848</code>.
- system_user: The user that the domain executes as. Defaults to `node['glassfish']['user']` if unset. Defaults to <code>nil</code>.
- system_group: The group that the domain executes as. Defaults to `node['glassfish']['group']` if unset. Defaults to <code>nil</code>.

## glassfish_managed_scheduled_executor_service

### Actions

- create:  Default action.
- delete:

### Attribute Parameters

- jndi_name:
- target:  Defaults to <code>"server"</code>.
- enabled: Determines whether container contexts are propagated to threads. If set to true, the contexts specified in the --contextinfo option are propagated. If set to false, no contexts are propagated and the --contextinfo option is ignored. Defaults to <code>true</code>.
- contextinfoenabled:  Defaults to <code>true</code>.
- contextinfo: Descriptive details about the resource. Defaults to <code>"Classloader,JNDI,Security,WorkArea"</code>.
- description:
- threadpriority: Specifies the priority to assign to created threads. Defaults to <code>5</code>.
- longrunningtasks: Specifies whether the resource should be used for long-running tasks. If set to true, long-running tasks are not reported as stuck. Defaults to <code>false</code>.
- hungafterseconds: Specifies the number of seconds that a task can execute before it is considered unresponsive. If the value is 0 tasks are never considered unresponsive. Defaults to <code>0</code>.
- corepoolsize: Specifies the number of threads to keep in a thread pool, even if they are idle. Defaults to <code>0</code>.
- keepaliveseconds: Specifies the number of seconds that threads can remain idle when the number of threads is greater than corepoolsize. Defaults to <code>60</code>.
- threadlifetimeseconds: Specifies the number of seconds that threads can remain in a thread pool before being purged, regardless of whether the number of threads is greater than corepoolsize or whether the threads are idle. The value of 0 means that threads are never purged. Defaults to <code>0</code>.
- domain_name: The name of the domain.
- terse: Use terse output from the underlying asadmin. Defaults to <code>false</code>.
- echo: If true, echo commands supplied to asadmin. Defaults to <code>true</code>.
- username: The username to use when communicating with the domain. Defaults to <code>nil</code>.
- password_file: The file in which the password must be stored assigned to appropriate key. Defaults to <code>nil</code>.
- secure: If true use SSL when communicating with the domain for administration. Defaults to <code>false</code>.
- admin_port: The port on which the web management console is bound. Defaults to <code>4848</code>.
- system_user: The user that the domain executes as. Defaults to `node['glassfish']['user']` if unset. Defaults to <code>nil</code>.
- system_group: The group that the domain executes as. Defaults to `node['glassfish']['group']` if unset. Defaults to <code>nil</code>.

## glassfish_managed_thread_factory

### Actions

- create:  Default action.
- delete:

### Attribute Parameters

- jndi_name:
- target:  Defaults to <code>"server"</code>.
- enabled: Determines whether container contexts are propagated to threads. If set to true, the contexts specified in the --contextinfo option are propagated. If set to false, no contexts are propagated and the --contextinfo option is ignored. Defaults to <code>true</code>.
- contextinfoenabled:  Defaults to <code>true</code>.
- contextinfo: Descriptive details about the resource. Defaults to <code>"Classloader,JNDI,Security,WorkArea"</code>.
- description:
- threadpriority: Specifies the priority to assign to created threads. Defaults to <code>5</code>.
- domain_name: The name of the domain.
- terse: Use terse output from the underlying asadmin. Defaults to <code>false</code>.
- echo: If true, echo commands supplied to asadmin. Defaults to <code>true</code>.
- username: The username to use when communicating with the domain. Defaults to <code>nil</code>.
- password_file: The file in which the password must be stored assigned to appropriate key. Defaults to <code>nil</code>.
- secure: If true use SSL when communicating with the domain for administration. Defaults to <code>false</code>.
- admin_port: The port on which the web management console is bound. Defaults to <code>4848</code>.
- system_user: The user that the domain executes as. Defaults to `node['glassfish']['user']` if unset. Defaults to <code>nil</code>.
- system_group: The group that the domain executes as. Defaults to `node['glassfish']['group']` if unset. Defaults to <code>nil</code>.

## glassfish_mq

Creates an OpenMQ message broker instance, creates an OS-level service and starts the service.

### Actions

- create: Create the message broker instance, enable and start the associated service. Default action.
- destroy: Stop the associated service and delete the instance directory and associated artifacts.

### Attribute Parameters

- max_memory: The amount of heap memory to allocate to the domain in MiB. Defaults to <code>512</code>.
- max_stack_size: The amount of stack memory to allocate to the domain in KiB. Defaults to <code>250</code>.
- instance: The name of the broker instance.
- users: A map of users to passwords for interacting with the service. Defaults to <code>{}</code>.
- access_control_rules: An access control list of patterns to users. Defaults to <code>{}</code>.
- logging_properties: A hash of properties that will be merged into logging.properties. Use this to send logs to syslog or graylog. Defaults to <code>{"handlers"=>"java.util.logging.ConsoleHandler", ".level"=>"INFO", "java.util.logging.ConsoleHandler.level"=>"INFO"}</code>.
- config: A map of key-value properties that are merged into the OpenMQ configuration file. Defaults to <code>{}</code>.
- queues: A map of queue names to queue properties. Defaults to <code>{}</code>.
- topics: A map of topic names to topic properties. Defaults to <code>{}</code>.
- jmx_admins: A map of username to password for read-write JMX admin interface. Ignored unless jmx_port is specified. Defaults to <code>{}</code>.
- jmx_monitors: A map of username to password for read-only JMX admin interface. Ignored unless jmx_port is specified. Defaults to <code>{}</code>.
- admin_user: The user in the users map that is used during administration. Defaults to <code>"imqadmin"</code>.
- port: The port for the portmapper to bind. Defaults to <code>7676</code>.
- admin_port: The port on which admin service will bind. Defaults to <code>7677</code>.
- jms_port: The port on which jms service will bind. Defaults to <code>7678</code>.
- jmx_port: The port on which jmx service will bind. If not specified, no jmx service will be exported. Defaults to <code>nil</code>.
- rmi_port: The port on which rmi service will bind. If not specified, a random port will be used. Typically used to lock down port for jmx access through firewalls. Defaults to <code>nil</code>.
- stomp_port: The port on which the stomp service will bind. If not specified, no stomp service will execute. Defaults to <code>nil</code>.
- system_user: The user that the domain executes as. Defaults to `node['glassfish']['user']` if unset. Defaults to <code>nil</code>.
- system_group: The group that the domain executes as. Defaults to `node['glassfish']['group']` if unset. Defaults to <code>nil</code>.
- init_style: The init system used to run the service. Defaults to <code>"upstart"</code>.

### Examples

    # Create a basic mq broker instance
    glassfish_mq "MessageBroker" do
      port 80
      jmx_port 8089
      jmx_admins { 'admin' => 'secret1' }
      jmx_monitors { 'monitoring_system' => 'secret2' }
      logging_properties {
        "handlers" => "java.util.logging.ConsoleHandler, gelf4j.logging.GelfHandler",
          ".level" => "INFO",
          "java.util.logging.ConsoleHandler.level" => "INFO",
          "gelf4j.logging.GelfHandler.level" => "ALL",
          "gelf4j.logging.GelfHandler.host" => 'graylog.example.org',
          "gelf4j.logging.GelfHandler.defaultFields" => '{"environment": "' + node.chef_environment + '", "facility": "MyInstance"}'
      }
      users { 'MyApp' => 'MyAppsPassword', 'MyOtherApp' => 'S3Cr37' }
      queues { 'MySystem.MyMessageQueue' => {'XMLSchemaURIList' => 'http://example.com/...'} }
      access_control_rules {
        'queue.MySystem.MyMessageQueue.browse.allow.user' => '*',
          'queue.MySystem.MyMessageQueue.produce.allow.user' => 'MyApp',
          'queue.MySystem.MyMessageQueue.consume.allow.user' => 'MyOtherApp'
      }
    end

## glassfish_mq_destination

Creates or deletes a queue or a topic in an OpenMQ message broker instance.

### Actions

- create: Create the destination. Default action.
- destroy: Destroy the destination.

### Attribute Parameters

- destination_name: The name of the destination.
- queue: True if the destination is a queue, false for a topic.
- config: The configuration settings for queue. Valid properties include those exposed by JMX. Also supports the key 'schema' containing a URL which expands to 'validateXMLSchemaEnabled=true' and 'XMLSchemaURIList=$uri'. Defaults to <code>{}</code>.
- host: The host of the OpenMQ message broker instance.
- port: The port of the portmapper service in message broker instance.
- username: The username used to connect to message broker. Defaults to <code>"imqadmin"</code>.
- passfile: The filename of a property file that contains a password for admin user set using the property "imq.imqcmd.password".
- system_user: The user that the domain executes as. Defaults to `node['glassfish']['user']` if unset. Defaults to <code>nil</code>.
- system_group: The group that the domain executes as. Defaults to `node['glassfish']['group']` if unset. Defaults to <code>nil</code>.

### Examples

    # Create a queue destination
    glassfish_destination "MySystem.MyMessageQueue" do
      queue true
      config {'schema' => 'http://example.org/MyMessageFormat.xsd'}
      host "localhost"
      port 7676
      username 'imqadmin'
      passfile '/etc/omq/omqadmin.pass'
    end

## glassfish_mq_ensure_running

Ensures that a OpenMQ message broker instance has had a chance to finish starting before proceeding.

### Actions

- run: Block until the broker has come online. Default action.

### Attribute Parameters

- host: The host on which the broker runs.
- port: The port on which the broker listens.

### Examples

    # Wait for OpenMQ broker to start
    glassfish_mq_ensure_running "wait for broker" do
      host "localhost"
      port 7676
    end

## glassfish_property

### Actions

- set:  Default action.

### Attribute Parameters

- key:
- value:
- domain_name: The name of the domain.
- terse: Use terse output from the underlying asadmin. Defaults to <code>false</code>.
- echo: If true, echo commands supplied to asadmin. Defaults to <code>true</code>.
- username: The username to use when communicating with the domain. Defaults to <code>nil</code>.
- password_file: The file in which the password must be stored assigned to appropriate key. Defaults to <code>nil</code>.
- secure: If true use SSL when communicating with the domain for administration. Defaults to <code>false</code>.
- admin_port: The port on which the web management console is bound. Defaults to <code>4848</code>.
- system_user: The user that the domain executes as. Defaults to `node['glassfish']['user']` if unset. Defaults to <code>nil</code>.
- system_group: The group that the domain executes as. Defaults to `node['glassfish']['group']` if unset. Defaults to <code>nil</code>.

## glassfish_property_cache

### Actions

- create:  Default action.
- delete:

### Attribute Parameters

- domain_name: The name of the domain.
- terse: Use terse output from the underlying asadmin. Defaults to <code>false</code>.
- echo: If true, echo commands supplied to asadmin. Defaults to <code>true</code>.
- username: The username to use when communicating with the domain. Defaults to <code>nil</code>.
- password_file: The file in which the password must be stored assigned to appropriate key. Defaults to <code>nil</code>.
- secure: If true use SSL when communicating with the domain for administration. Defaults to <code>false</code>.
- admin_port: The port on which the web management console is bound. Defaults to <code>4848</code>.
- system_user: The user that the domain executes as. Defaults to `node['glassfish']['user']` if unset. Defaults to <code>nil</code>.
- system_group: The group that the domain executes as. Defaults to `node['glassfish']['group']` if unset. Defaults to <code>nil</code>.

## glassfish_resource_adapter

### Actions

- create:  Default action.
- delete:

### Attribute Parameters

- resource_adapter_name:
- threadpoolid:  Defaults to <code>nil</code>.
- objecttype:  Defaults to <code>nil</code>.
- properties:  Defaults to <code>{}</code>.
- domain_name: The name of the domain.
- terse: Use terse output from the underlying asadmin. Defaults to <code>false</code>.
- echo: If true, echo commands supplied to asadmin. Defaults to <code>true</code>.
- username: The username to use when communicating with the domain. Defaults to <code>nil</code>.
- password_file: The file in which the password must be stored assigned to appropriate key. Defaults to <code>nil</code>.
- secure: If true use SSL when communicating with the domain for administration. Defaults to <code>false</code>.
- admin_port: The port on which the web management console is bound. Defaults to <code>4848</code>.
- system_user: The user that the domain executes as. Defaults to `node['glassfish']['user']` if unset. Defaults to <code>nil</code>.
- system_group: The group that the domain executes as. Defaults to `node['glassfish']['group']` if unset. Defaults to <code>nil</code>.

## glassfish_secure_admin

Enable or disable secure admin flag on the GlassFish server which enables/disables remote administration.

### Actions

- enable: Enable remote access/secure admin. Default action.
- disable: Disable remote access/secure admin.

### Attribute Parameters

- domain_name: The name of the domain.
- terse: Use terse output from the underlying asadmin. Defaults to <code>false</code>.
- echo: If true, echo commands supplied to asadmin. Defaults to <code>true</code>.
- username: The username to use when communicating with the domain. Defaults to <code>nil</code>.
- password_file: The file in which the password must be stored assigned to appropriate key. Defaults to <code>nil</code>.
- secure: If true use SSL when communicating with the domain for administration. Defaults to <code>false</code>.
- admin_port: The port on which the web management console is bound. Defaults to <code>4848</code>.
- system_user: The user that the domain executes as. Defaults to `node['glassfish']['user']` if unset. Defaults to <code>nil</code>.
- system_group: The group that the domain executes as. Defaults to `node['glassfish']['group']` if unset. Defaults to <code>nil</code>.

### Examples

    glassfish_secure_admin "My Domain Remote Access" do
       action :enable
    end

## glassfish_thread_pool

### Actions

- create:  Default action.
- delete:

### Attribute Parameters

- threadpool_id:
- target:  Defaults to <code>"server"</code>.
- maxthreadpoolsize: Specifies the maximum number of threads the pool can contain. Defaults to <code>5</code>.
- minthreadpoolsize: Specifies the minimum number of threads in the pool. These are created when the thread pool is instantiated. Defaults to <code>2</code>.
- idletimeout: Specifies the amount of time in seconds after which idle threads are removed from the pool. Defaults to <code>900</code>.
- maxqueuesize: Specifies the maximum number of messages that can be queued until threads are available to process them for a network listener or IIOP listener. A value of -1 specifies no limit. Defaults to <code>4096</code>.
- domain_name: The name of the domain.
- terse: Use terse output from the underlying asadmin. Defaults to <code>false</code>.
- echo: If true, echo commands supplied to asadmin. Defaults to <code>true</code>.
- username: The username to use when communicating with the domain. Defaults to <code>nil</code>.
- password_file: The file in which the password must be stored assigned to appropriate key. Defaults to <code>nil</code>.
- secure: If true use SSL when communicating with the domain for administration. Defaults to <code>false</code>.
- admin_port: The port on which the web management console is bound. Defaults to <code>4848</code>.
- system_user: The user that the domain executes as. Defaults to `node['glassfish']['user']` if unset. Defaults to <code>nil</code>.
- system_group: The group that the domain executes as. Defaults to `node['glassfish']['group']` if unset. Defaults to <code>nil</code>.

## glassfish_web_env_entry

Set a value that can be retrieved as a `web env entry` in a particular web application. This resource is idempotent and
will not set the entry if it already exists and has the same value. Nil values can be specified. The java type of the
value must also be specified.

### Actions

- set: Set the value as entry. Default action.
- unset: Remove the entry.

### Attribute Parameters

- webapp: The name of the web application name.
- name: The key name of the web env entry.
- type: The java type name of env entry. Defaults to <code>"java.lang.String"</code>.
- value: The value of the entry. Defaults to <code>nil</code>.
- description: A description of the entry. Defaults to <code>nil</code>.
- domain_name: The name of the domain.
- terse: Use terse output from the underlying asadmin. Defaults to <code>false</code>.
- echo: If true, echo commands supplied to asadmin. Defaults to <code>true</code>.
- username: The username to use when communicating with the domain. Defaults to <code>nil</code>.
- password_file: The file in which the password must be stored assigned to appropriate key. Defaults to <code>nil</code>.
- secure: If true use SSL when communicating with the domain for administration. Defaults to <code>false</code>.
- admin_port: The port on which the web management console is bound. Defaults to <code>4848</code>.
- system_user: The user that the domain executes as. Defaults to `node['glassfish']['user']` if unset. Defaults to <code>nil</code>.
- system_group: The group that the domain executes as. Defaults to `node['glassfish']['group']` if unset. Defaults to <code>nil</code>.

### Examples

    glassfish_web_env_entry "Set IntegrationServerURL" do
       domain_name 'my_domain'
       name 'IntegrationServerURL'
       value 'http://example.com/Foo'
       type 'java.lang.String'
    end

# License and Maintainer

Maintainer:: Peter Donald

License:: Apache 2.0
