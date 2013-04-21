# Description

[![Build Status](https://secure.travis-ci.org/realityforge/chef-glassfish.png?branch=master)](http://travis-ci.org/realityforge/chef-glassfish)

The glassfish cookbook installs and configures the GlassFish application server and the OpenMQ message broker bundled
with the GlassFish application server. The cookbook also defines resources to create and configure GlassFish
application domains and OpenMQ broker instances.

# Requirements

## Platform:

* Ubuntu

## Cookbooks:

* java
* authbind
* cutlery (~> 0.1)

# Attributes

* `node['glassfish']['user']` - The user that GlassFish executes as. Defaults to `glassfish`.
* `node['glassfish']['group']` - The group allowed to manage GlassFish domains. Defaults to `glassfish-admin`.
* `node['glassfish']['package_url']` - The url to the GlassFish install package. Defaults to `http://dlc.sun.com.edgesuite.net/glassfish/3.1.2/release/glassfish-3.1.2.zip`.
* `node['glassfish']['base_dir']` - The base directory of the GlassFish install. Defaults to `/usr/local/glassfish`.
* `node['glassfish']['domains_dir']` - The directory containing all the domain definitions. Defaults to `/usr/local/glassfish/glassfish/domains`.
* `node['glassfish']['domains']` - A map of domain definitions that drive the instantiation of a domain. Defaults to `{}`.
* `node['openmq']['instances']` - A map of broker definitions that drive the instantiation of a OpenMQ broker. Defaults to `{}`.
* `node['openmq']['extra_libraries']` - A list of URLs to jars that are added to brokers classpath. Defaults to `{}`.

# Recipes

* [glassfish::default](#glassfishdefault) - Installs the GlassFish binaries.
* [glassfish::attribute_driven_domain](#glassfishattribute_driven_domain) - Configures 0 or more GlassFish domains using the glassfish/domains attribute.
* glassfish::search_driven_domain - Configures 0 or more GlassFish domains using search to generate the configuration.
* [glassfish::attribute_driven_mq](#glassfishattribute_driven_mq) - Configures 0 or more GlassFish OpenMQ brokers using the openmq/instances attribute.

## glassfish::default

Downloads, and extracts the glassfish binaries, creates the glassfish user and group.

Does not create any Application Server or Message Broker instances. This recipe is not
typically included directly but is included transitively through either <code>glassfish::attribute_driven_domain</code>
or <code>glassfish::attribute_driven_mq</code>.

## glassfish::attribute_driven_domain

The `attribute_driven_domain` recipe interprets attributes on the node and defines the resources described in the attributes.

## glassfish::attribute_driven_mq

The `attribute_driven_mq` recipe interprets attributes on the node and defines the resources described in the attributes.

# Resources

* [glassfish_admin_object](#glassfish_admin_object)
* [glassfish_asadmin](#glassfish_asadmin) - Asadmin is the command line application used to manage a GlassFish application server.
* [glassfish_auth_realm](#glassfish_auth_realm)
* [glassfish_connector_connection_pool](#glassfish_connector_connection_pool)
* [glassfish_connector_resource](#glassfish_connector_resource)
* [glassfish_custom_resource](#glassfish_custom_resource)
* [glassfish_deployable](#glassfish_deployable)
* [glassfish_domain](#glassfish_domain) - Creates a GlassFish application domain, creates an OS-level service and starts the service.
* [glassfish_javamail_resource](#glassfish_javamail_resource)
* [glassfish_jdbc_connection_pool](#glassfish_jdbc_connection_pool)
* [glassfish_jdbc_resource](#glassfish_jdbc_resource)
* [glassfish_library](#glassfish_library)
* [glassfish_mq](#glassfish_mq) - Creates an OpenMQ message broker instance, creates an OS-level service and starts the service.
* [glassfish_mq_destination](#glassfish_mq_destination) - Creates or deletes a queue or a topic in an OpenMQ message broker instance.
* [glassfish_property](#glassfish_property)
* [glassfish_resource_adapter](#glassfish_resource_adapter)
* [glassfish_secure_admin](#glassfish_secure_admin) - Enable or disable secure admin flag on the GlassFish server which enables/disables remote administration.
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
- url: 
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
- domain_name: The name of the domain.
- terse: Use terse output from the underlying asadmin. Defaults to <code>false</code>.
- echo: If true, echo commands supplied to asadmin. Defaults to <code>true</code>.
- username: The username to use when communicating with the domain. Defaults to <code>nil</code>.
- password_file: The file in which the password must be stored assigned to appropriate key. Defaults to <code>nil</code>.
- secure: If true use SSL when communicating with the domain for administration. Defaults to <code>false</code>.
- admin_port: The port on which the web management console is bound. Defaults to <code>4848</code>.

## glassfish_domain

Creates a GlassFish application domain, creates an OS-level service and starts the service.

### Actions

- create: Create the domain, enable and start the associated service. Default action.
- destroy: Stop the associated service and delete the domain directory and associated artifacts.

### Attribute Parameters

- min_memory:  Defaults to <code>512</code>.
- max_memory: The amount of heap memory to allocate to the domain in MiB. Defaults to <code>512</code>.
- max_perm_size: The amount of perm gen memory to allocate to the domain in MiB. Defaults to <code>96</code>.
- max_stack_size: The amount of stack memory to allocate to the domain in KiB. Defaults to <code>128</code>.
- port: The port on which the HTTP service will bind. Defaults to <code>8080</code>.
- admin_port: The port on which the web management console is bound. Defaults to <code>4848</code>.
- extra_jvm_options: An array of extra arguments to pass the JVM. Defaults to <code>[]</code>.
- env_variables: A hash of environment variables set when running the domain. Defaults to <code>{}</code>.
- domain_name: The name of the domain.
- terse: Use terse output from the underlying asadmin. Defaults to <code>false</code>.
- echo: If true, echo commands supplied to asadmin. Defaults to <code>true</code>.
- username: The username to use when communicating with the domain. Defaults to <code>nil</code>.
- password: Password to use when communicating with the domain. Must be set if username is set. Defaults to <code>nil</code>.
- password_file: The file in which the password is saved. Should be set if username is set. Defaults to <code>nil</code>.
- secure: If true use SSL when communicating with the domain for administration. Defaults to <code>false</code>.
- logging_properties: A hash of properties that will be merged into logging.properties. Use this to send logs to syslog or graylog. Defaults to <code>{}</code>.
- realm_types: A map of names to realm implementation classes that is merged into the default realm types. Defaults to <code>{}</code>.

### Examples

    # Create a basic domain that logs to a central graylog server
    glassfish_domain "my_domain" do
      port 80
      admin_port 8103
      extra_libraries ['https://github.com/downloads/realityforge/gelf4j/gelf4j-0.9-all.jar']
      logging_properties {
        "handlers" => "java.util.logging.ConsoleHandler, gelf4j.logging.GelfHandler",
        ".level" => "INFO",
        "java.util.logging.ConsoleHandler.level" => "INFO",
        "gelf4j.logging.GelfHandler.level" => "ALL",
        "gelf4j.logging.GelfHandler.host" => 'graylog.example.org',
        "gelf4j.logging.GelfHandler.defaultFields" => '{"environment": "' + node.chef_environment + '", "facility": "MyDomain"}'
      }
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

## glassfish_jdbc_connection_pool

### Actions

- create:  Default action.
- delete: 

### Attribute Parameters

- pool_name: 
- datasourceclassname:  Defaults to <code>nil</code>.
- initsql:  Defaults to <code>nil</code>.
- sqltracelisteners:  Defaults to <code>nil</code>.
- driverclassname:  Defaults to <code>nil</code>.
- validationclassname:  Defaults to <code>nil</code>.
- validationtable:  Defaults to <code>nil</code>.
- steadypoolsize:  Defaults to <code>nil</code>.
- maxpoolsize:  Defaults to <code>nil</code>.
- maxwait:  Defaults to <code>nil</code>.
- poolresize:  Defaults to <code>nil</code>.
- idletimeout:  Defaults to <code>nil</code>.
- validateatmostonceperiod:  Defaults to <code>nil</code>.
- leaktimeout:  Defaults to <code>nil</code>.
- statementleaktimeout:  Defaults to <code>nil</code>.
- creationretryattempts:  Defaults to <code>nil</code>.
- creationretryinterval:  Defaults to <code>nil</code>.
- statementtimeout:  Defaults to <code>nil</code>.
- maxconnectionusagecount:  Defaults to <code>nil</code>.
- statementcachesize:  Defaults to <code>nil</code>.
- isisolationguaranteed:  Defaults to <code>nil</code>.
- isconnectvalidatereq:  Defaults to <code>nil</code>.
- failconnection:  Defaults to <code>nil</code>.
- allownoncomponentcallers:  Defaults to <code>nil</code>.
- nontransactionalconnections:  Defaults to <code>nil</code>.
- statmentleakreclaim:  Defaults to <code>nil</code>.
- leakreclaim:  Defaults to <code>nil</code>.
- lazyconnectionenlistment:  Defaults to <code>nil</code>.
- lazyconnectionassociation:  Defaults to <code>nil</code>.
- associatewiththread:  Defaults to <code>nil</code>.
- matchconnections:  Defaults to <code>nil</code>.
- ping:  Defaults to <code>nil</code>.
- pooling:  Defaults to <code>nil</code>.
- wrapjdbcobjects:  Defaults to <code>nil</code>.
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

## glassfish_library

### Actions

- add:  Default action.
- remove: 

### Attribute Parameters

- url: 
- library_type:  Defaults to <code>"common"</code>.
- upload:  Defaults to <code>true</code>.
- domain_name: The name of the domain.
- terse: Use terse output from the underlying asadmin. Defaults to <code>false</code>.
- echo: If true, echo commands supplied to asadmin. Defaults to <code>true</code>.
- username: The username to use when communicating with the domain. Defaults to <code>nil</code>.
- password_file: The file in which the password must be stored assigned to appropriate key. Defaults to <code>nil</code>.
- secure: If true use SSL when communicating with the domain for administration. Defaults to <code>false</code>.
- admin_port: The port on which the web management console is bound. Defaults to <code>4848</code>.

## glassfish_mq

Creates an OpenMQ message broker instance, creates an OS-level service and starts the service.

### Actions

- create: Create the message broker instance, enable and start the associated service. Default action.
- destroy: Stop the associated service and delete the instance directory and associated artifacts.

### Attribute Parameters

- max_memory: The amount of heap memory to allocate to the domain in MiB. Defaults to <code>512</code>.
- max_stack_size: The amount of stack memory to allocate to the domain in KiB. Defaults to <code>128</code>.
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
- stomp_port: The port on which the stomp service will bind. If not specified, no stomp service will execute. Defaults to <code>nil</code>.

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

### Examples

    glassfish_secure_admin "My Domain Remote Access" do
       action :enable
    end

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
