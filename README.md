Description
===========

Installs/Configures GlassFish Application Server

Requirements
============

## Platform:

* Ubuntu

## Cookbooks:

* java
* authbind
* cutlery (~> 0.1)

Attributes
==========

<table>
  <tr>
    <td>Attribute</td>
    <td>Description</td>
    <td>Default</td>
  </tr>
  <tr>
    <td><code>node['glassfish']['user']</code></td>
    <td>The user that GlassFish executes as</td>
    <td><code>glassfish</code></td>
  </tr>
  <tr>
    <td><code>node['glassfish']['group']</code></td>
    <td>The group allowed to manage GlassFish domains</td>
    <td><code>glassfish-admin</code></td>
  </tr>
  <tr>
    <td><code>node['glassfish']['package_url']</code></td>
    <td>The url to the GlassFish install package</td>
    <td><code>http://dlc.sun.com.edgesuite.net/glassfish/3.1.2/release/glassfish-3.1.2.zip</code></td>
  </tr>
  <tr>
    <td><code>node['glassfish']['base_dir']</code></td>
    <td>The base directory of the GlassFish install</td>
    <td><code>/usr/local/glassfish</code></td>
  </tr>
  <tr>
    <td><code>node['glassfish']['domains_dir']</code></td>
    <td>The directory containing all the domain definitions</td>
    <td><code>/usr/local/glassfish/glassfish/domains</code></td>
  </tr>
  <tr>
    <td><code>node['glassfish']['domains']</code></td>
    <td>A map of domain definitions that drive the instantiation of a domain</td>
    <td><code>{}</code></td>
  </tr>
  <tr>
    <td><code>node['openmq']['instances']</code></td>
    <td>A map of broker definitions that drive the instantiation of a OpenMQ broker</td>
    <td><code>{}</code></td>
  </tr>
  <tr>
    <td><code>node['openmq']['extra_libraries']</code></td>
    <td>A list of URLs to jars that are added to brokers classpath</td>
    <td><code>{}</code></td>
  </tr>
</table>

Recipes
=======

## glassfish::default

Installs and configures GlassFish

## glassfish::attribute_driven_domain

Installs GlassFish domains defined in the glassfish/domains attribute

## glassfish::attribute_driven_mq

Installs GlassFish OpenMQ brokers defined in the openmq/instances attribute


Resources
=========
# glassfish_admin_object



### Actions

- create: Default Action.
- delete: 

### Attribute Parameters

- jndi_name: 
- raname: 
- restype: 
- enabled: Defaults to true.
- target: Defaults to "server".
- classname: Defaults to nil.
- description: Defaults to nil.
- properties: Defaults to \{\}.
- domain_name: 
- terse: Defaults to false.
- echo: Defaults to true.
- username: Defaults to nil.
- password_file: Defaults to nil.
- secure: Defaults to false.
- admin_port: Defaults to 4848.


# glassfish_asadmin



### Actions

- run: Default Action.

### Attribute Parameters

- command: 
- domain_name: 
- terse: Defaults to false.
- echo: Defaults to true.
- username: Defaults to nil.
- password_file: Defaults to nil.
- secure: Defaults to false.
- admin_port: Defaults to 4848.
- returns: Defaults to 0.


# glassfish_auth_realm



### Actions

- create: Default Action.
- delete: 

### Attribute Parameters

- realm_name: 
- target: Defaults to "server".
- classname: 
- jaas_context: Defaults to nil.
- assign_groups: Defaults to nil.
- properties: Defaults to \{\}.
- domain_name: 
- terse: Defaults to false.
- echo: Defaults to true.
- username: Defaults to nil.
- password_file: Defaults to nil.
- secure: Defaults to false.
- admin_port: Defaults to 4848.


# glassfish_connector_connection_pool



### Actions

- create: Default Action.
- delete: 

### Attribute Parameters

- pool_name: 
- description: Defaults to nil.
- raname: 
- connectiondefinition: 
- steadypoolsize: Defaults to nil.
- maxpoolsize: Defaults to nil.
- maxwait: Defaults to nil.
- poolresize: Defaults to nil.
- idletimeout: Defaults to nil.
- leaktimeout: Defaults to nil.
- validateatmostonceperiod: Defaults to nil.
- maxconnectionusagecount: Defaults to nil.
- creationretryattempts: Defaults to nil.
- creationretryinterval: Defaults to nil.
- isconnectvalidatereq: Defaults to nil.
- failconnection: Defaults to nil.
- leakreclaim: Defaults to nil.
- lazyconnectionenlistment: Defaults to nil.
- lazyconnectionassociation: Defaults to nil.
- associatewiththread: Defaults to nil.
- matchconnections: Defaults to nil.
- ping: Defaults to nil.
- pooling: Defaults to nil.
- properties: Defaults to \{\}.
- transactionsupport: 
- domain_name: 
- terse: Defaults to false.
- echo: Defaults to true.
- username: Defaults to nil.
- password_file: Defaults to nil.
- secure: Defaults to false.
- admin_port: Defaults to 4848.


# glassfish_connector_resource



### Actions

- create: Default Action.
- delete: 

### Attribute Parameters

- resource_name: 
- poolname: 
- enabled: Defaults to true.
- target: Defaults to "server".
- objecttype: Defaults to nil.
- description: Defaults to nil.
- properties: Defaults to \{\}.
- domain_name: 
- terse: Defaults to false.
- echo: Defaults to true.
- username: Defaults to nil.
- password_file: Defaults to nil.
- secure: Defaults to false.
- admin_port: Defaults to 4848.


# glassfish_custom_resource



### Actions

- create: Default Action.
- delete: 

### Attribute Parameters

- jndi_name: 
- target: Defaults to "server".
- restype: Defaults to "java\.lang\.String".
- factoryclass: Defaults to "org\.glassfish\.resources\.custom\.factory\.PrimitivesAndStringFactory".
- enabled: Defaults to true.
- description: Defaults to nil.
- properties: Defaults to \{\}.
- value: Defaults to nil.
- domain_name: 
- terse: Defaults to false.
- echo: Defaults to true.
- username: Defaults to nil.
- password_file: Defaults to nil.
- secure: Defaults to false.
- admin_port: Defaults to 4848.


# glassfish_deployable



### Actions

- deploy: Default Action.
- disable: 
- enable: 
- undeploy: 

### Attribute Parameters

- component_name: 
- version: Defaults to nil.
- target: Defaults to "server".
- url: 
- enabled: Defaults to true.
- type: Defaults to nil.
- context_root: Defaults to nil.
- virtual_servers: Defaults to \[\].
- generate_rmi_stubs: Defaults to false.
- availability_enabled: Defaults to false.
- lb_enabled: Defaults to true.
- keep_state: Defaults to false.
- verify: Defaults to false.
- precompile_jsp: Defaults to true.
- async_replication: Defaults to true.
- properties: Defaults to \{\}.
- descriptors: Defaults to \{\}.
- domain_name: 
- terse: Defaults to false.
- echo: Defaults to true.
- username: Defaults to nil.
- password_file: Defaults to nil.
- secure: Defaults to false.
- admin_port: Defaults to 4848.


# glassfish_domain



### Actions

- create: Default Action.
- destroy: 

### Attribute Parameters

- min_memory: Defaults to 512.
- max_memory: Defaults to 512.
- max_perm_size: Defaults to 96.
- max_stack_size: Defaults to 128.
- port: Defaults to 8080.
- admin_port: Defaults to 4848.
- extra_jvm_options: Defaults to \[\].
- env_variables: Defaults to \{\}.
- domain_name: 
- terse: Defaults to false.
- echo: Defaults to true.
- username: Defaults to nil.
- password: Defaults to nil.
- password_file: Defaults to nil.
- secure: Defaults to false.
- logging_properties: Defaults to \{\}.
- realm_types: Defaults to \{\}.


# glassfish_javamail_resource



### Actions

- create: Default Action.
- delete: 

### Attribute Parameters

- jndi_name: 
- target: Defaults to "server".
- mailhost: 
- mailuser: 
- fromaddress: 
- storeprotocol: 
- storeprotocolclass: 
- transprotocol: 
- transprotocolclass: 
- debug: Defaults to nil.
- enabled: Defaults to true.
- description: Defaults to nil.
- properties: Defaults to \{\}.
- domain_name: 
- terse: Defaults to false.
- echo: Defaults to true.
- username: Defaults to nil.
- password_file: Defaults to nil.
- secure: Defaults to false.
- admin_port: Defaults to 4848.


# glassfish_jdbc_connection_pool



### Actions

- create: Default Action.
- delete: 

### Attribute Parameters

- pool_name: 
- datasourceclassname: Defaults to nil.
- initsql: Defaults to nil.
- sqltracelisteners: Defaults to nil.
- driverclassname: Defaults to nil.
- validationclassname: Defaults to nil.
- validationtable: Defaults to nil.
- steadypoolsize: Defaults to nil.
- maxpoolsize: Defaults to nil.
- maxwait: Defaults to nil.
- poolresize: Defaults to nil.
- idletimeout: Defaults to nil.
- validateatmostonceperiod: Defaults to nil.
- leaktimeout: Defaults to nil.
- statementleaktimeout: Defaults to nil.
- creationretryattempts: Defaults to nil.
- creationretryinterval: Defaults to nil.
- statementtimeout: Defaults to nil.
- maxconnectionusagecount: Defaults to nil.
- statementcachesize: Defaults to nil.
- isisolationguaranteed: Defaults to nil.
- isconnectvalidatereq: Defaults to nil.
- failconnection: Defaults to nil.
- allownoncomponentcallers: Defaults to nil.
- nontransactionalconnections: Defaults to nil.
- statmentleakreclaim: Defaults to nil.
- leakreclaim: Defaults to nil.
- lazyconnectionenlistment: Defaults to nil.
- lazyconnectionassociation: Defaults to nil.
- associatewiththread: Defaults to nil.
- matchconnections: Defaults to nil.
- ping: Defaults to nil.
- pooling: Defaults to nil.
- wrapjdbcobjects: Defaults to nil.
- description: Defaults to nil.
- properties: Defaults to \{\}.
- restype: Defaults to nil.
- isolationlevel: 
- validationmethod: 
- domain_name: 
- terse: Defaults to false.
- echo: Defaults to true.
- username: Defaults to nil.
- password_file: Defaults to nil.
- secure: Defaults to false.
- admin_port: Defaults to 4848.


# glassfish_jdbc_resource



### Actions

- create: Default Action.
- delete: 

### Attribute Parameters

- resource_name: 
- connectionpoolid: 
- enabled: Defaults to true.
- target: Defaults to "server".
- description: Defaults to nil.
- properties: Defaults to \{\}.
- domain_name: 
- terse: Defaults to false.
- echo: Defaults to true.
- username: Defaults to nil.
- password_file: Defaults to nil.
- secure: Defaults to false.
- admin_port: Defaults to 4848.


# glassfish_library



### Actions

- add: Default Action.
- remove: 

### Attribute Parameters

- url: 
- library_type: Defaults to "common".
- upload: Defaults to true.
- domain_name: 
- terse: Defaults to false.
- echo: Defaults to true.
- username: Defaults to nil.
- password_file: Defaults to nil.
- secure: Defaults to false.
- admin_port: Defaults to 4848.


# glassfish_mq

Creates an OpenMQ message broker instance, creates an OS-level service and starts the service.



### Actions

- create: Create the message broker instance, enable and start the associated service. Default Action.
- destroy: Stop the associated service and delete the instance directory and associated artifacts.

### Attribute Parameters

- max_memory: The amount of heap memory to allocate to the domain in MiB. Defaults to 512.
- max_stack_size: The amount of stack memory to allocate to the domain in KiB. Defaults to 128.
- instance: The name of the broker instance.
- users: A map of users to passwords for interacting with the service. Defaults to \{\}.
- access_control_rules: An access control list of patterns to users. Defaults to \{\}.
- logging_properties: A hash of properties that will be merged into logging.properties. Use this to send logs to syslog or graylog. Defaults to \{"handlers"=>"java\.util\.logging\.ConsoleHandler", "\.level"=>"INFO", "java\.util\.logging\.ConsoleHandler\.level"=>"INFO"\}.
- config: A map of key-value properties that are merged into the OpenMQ configuration file. Defaults to \{\}.
- queues: A map of queue names to queue properties. Defaults to \{\}.
- topics: A map of topic names to topic properties. Defaults to \{\}.
- jmx_admins: A map of username to password for read-write JMX admin interface. Ignored unless jmx_port is specified. Defaults to \{\}.
- jmx_monitors: A map of username to password for read-only JMX admin interface. Ignored unless jmx_port is specified. Defaults to \{\}.
- admin_user: The user in the users map that is used during administration. Defaults to "imqadmin".
- port: The port for the portmapper to bind. Defaults to 7676.
- admin_port: The port on which admin service will bind. Defaults to 7677.
- jms_port: The port on which jms service will bind. Defaults to 7678.
- jmx_port: The port on which jmx service will bind. If not specified, no jmx service will be exported. Defaults to nil.
- stomp_port: The port on which the stomp service will bind. If not specified, no stomp service will execute. Defaults to nil.

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
          "gelf4j.logging.GelfHandler.defaultFields" => '{"environment": "' + node.chef_environment + '", "facility": "MyInstance"}',
          "gelf4j.logging.GelfHandler.compressedChunking" => false,
      }
      users { 'MyApp' => 'MyAppsPassword', 'MyOtherApp' => 'S3Cr37' }
      queues { 'MySystem.MyMessageQueue' => {'XMLSchemaURIList' => 'http://example.com/...'} }
      access_control_rules {
        'queue.MySystem.MyMessageQueue.browse.allow.user' => '*',
          'queue.MySystem.MyMessageQueue.produce.allow.user' => 'MyApp',
          'queue.MySystem.MyMessageQueue.consume.allow.user' => 'MyOtherApp'
      }
    end



# glassfish_mq_destination



### Actions

- create: Default Action.
- destroy: 

### Attribute Parameters

- destination_name: 
- queue: 
- config: Defaults to \{\}.
- host: 
- port: 
- username: Defaults to "imqadmin".
- passfile: 


# glassfish_property



### Actions

- set: Default Action.

### Attribute Parameters

- key: 
- value: 
- domain_name: 
- terse: Defaults to false.
- echo: Defaults to true.
- username: Defaults to nil.
- password_file: Defaults to nil.
- secure: Defaults to false.
- admin_port: Defaults to 4848.


# glassfish_resource_adapter



### Actions

- create: Default Action.
- delete: 

### Attribute Parameters

- resource_adapter_name: 
- threadpoolid: Defaults to nil.
- objecttype: Defaults to nil.
- properties: Defaults to \{\}.
- domain_name: 
- terse: Defaults to false.
- echo: Defaults to true.
- username: Defaults to nil.
- password_file: Defaults to nil.
- secure: Defaults to false.
- admin_port: Defaults to 4848.


# glassfish_secure_admin



### Actions

- enable: Default Action.
- disable: 

### Attribute Parameters

- domain_name: 
- terse: Defaults to false.
- echo: Defaults to true.
- username: Defaults to nil.
- password_file: Defaults to nil.
- secure: Defaults to false.
- admin_port: Defaults to 4848.


# glassfish_web_env_entry



### Actions

- set: Default Action.
- unset: 

### Attribute Parameters

- webapp: 
- name: 
- type: Defaults to "java\.lang\.String".
- value: Defaults to nil.
- description: Defaults to nil.
- domain_name: 
- terse: Defaults to false.
- echo: Defaults to true.
- username: Defaults to nil.
- password_file: Defaults to nil.
- secure: Defaults to false.
- admin_port: Defaults to 4848.




License and Author
==================

Author:: Peter Donald (<peter@realityforge.org>)

Copyright:: 2013, Peter Donald

License:: Apache 2.0
