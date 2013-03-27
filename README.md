# Description

Installs/Configures GlassFish Application Server

# Requirements

## Platform:

* Ubuntu

## Cookbooks:

* java
* authbind
* cutlery (~> 0.1)

# Attributes

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

# Recipes

* [glassfish::default](#glassfishdefault) - Installs and configures GlassFish
* glassfish::attribute_driven_domain - Installs GlassFish domains defined in the glassfish/domains attribute
* glassfish::attribute_driven_mq - Installs GlassFish OpenMQ brokers defined in the openmq/instances attribute

## glassfish::default

Downloads, and extracts the glassfish binaries, creates the glassfish user and group.

Does not create any Application Server or Message Broker instances. This recipe is not
typically included directly but is included transitively through either <code>glassfish::attribute_driven_domain</code>
or <code>glassfish::attribute_driven_mq</code>.

# Resources

* [glassfish_admin_object](#glassfish_admin_object)
* [glassfish_asadmin](#glassfish_asadmin)
* [glassfish_auth_realm](#glassfish_auth_realm)
* [glassfish_connector_connection_pool](#glassfish_connector_connection_pool)
* [glassfish_connector_resource](#glassfish_connector_resource)
* [glassfish_custom_resource](#glassfish_custom_resource)
* [glassfish_deployable](#glassfish_deployable)
* [glassfish_domain](#glassfish_domain)
* [glassfish_javamail_resource](#glassfish_javamail_resource)
* [glassfish_jdbc_connection_pool](#glassfish_jdbc_connection_pool)
* [glassfish_jdbc_resource](#glassfish_jdbc_resource)
* [glassfish_library](#glassfish_library)
* [glassfish_mq](#glassfish_mq) - Creates an OpenMQ message broker instance, creates an OS-level service and starts the service
* [glassfish_mq_destination](#glassfish_mq_destination)
* [glassfish_property](#glassfish_property)
* [glassfish_resource_adapter](#glassfish_resource_adapter)
* [glassfish_secure_admin](#glassfish_secure_admin)
* [glassfish_web_env_entry](#glassfish_web_env_entry)

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
- domain_name: 
- terse:  Defaults to <code>false</code>.
- echo:  Defaults to <code>true</code>.
- username:  Defaults to <code>nil</code>.
- password_file:  Defaults to <code>nil</code>.
- secure:  Defaults to <code>false</code>.
- admin_port:  Defaults to <code>4848</code>.

## glassfish_asadmin

### Actions

- run:  Default action.

### Attribute Parameters

- command: 
- domain_name: 
- terse:  Defaults to <code>false</code>.
- echo:  Defaults to <code>true</code>.
- username:  Defaults to <code>nil</code>.
- password_file:  Defaults to <code>nil</code>.
- secure:  Defaults to <code>false</code>.
- admin_port:  Defaults to <code>4848</code>.
- returns:  Defaults to <code>0</code>.

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
- domain_name: 
- terse:  Defaults to <code>false</code>.
- echo:  Defaults to <code>true</code>.
- username:  Defaults to <code>nil</code>.
- password_file:  Defaults to <code>nil</code>.
- secure:  Defaults to <code>false</code>.
- admin_port:  Defaults to <code>4848</code>.

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
- domain_name: 
- terse:  Defaults to <code>false</code>.
- echo:  Defaults to <code>true</code>.
- username:  Defaults to <code>nil</code>.
- password_file:  Defaults to <code>nil</code>.
- secure:  Defaults to <code>false</code>.
- admin_port:  Defaults to <code>4848</code>.

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
- domain_name: 
- terse:  Defaults to <code>false</code>.
- echo:  Defaults to <code>true</code>.
- username:  Defaults to <code>nil</code>.
- password_file:  Defaults to <code>nil</code>.
- secure:  Defaults to <code>false</code>.
- admin_port:  Defaults to <code>4848</code>.

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
- domain_name: 
- terse:  Defaults to <code>false</code>.
- echo:  Defaults to <code>true</code>.
- username:  Defaults to <code>nil</code>.
- password_file:  Defaults to <code>nil</code>.
- secure:  Defaults to <code>false</code>.
- admin_port:  Defaults to <code>4848</code>.

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
- domain_name: 
- terse:  Defaults to <code>false</code>.
- echo:  Defaults to <code>true</code>.
- username:  Defaults to <code>nil</code>.
- password_file:  Defaults to <code>nil</code>.
- secure:  Defaults to <code>false</code>.
- admin_port:  Defaults to <code>4848</code>.

## glassfish_domain

### Actions

- create:  Default action.
- destroy: 

### Attribute Parameters

- min_memory:  Defaults to <code>512</code>.
- max_memory:  Defaults to <code>512</code>.
- max_perm_size:  Defaults to <code>96</code>.
- max_stack_size:  Defaults to <code>128</code>.
- port:  Defaults to <code>8080</code>.
- admin_port:  Defaults to <code>4848</code>.
- extra_jvm_options:  Defaults to <code>[]</code>.
- env_variables:  Defaults to <code>{}</code>.
- domain_name: 
- terse:  Defaults to <code>false</code>.
- echo:  Defaults to <code>true</code>.
- username:  Defaults to <code>nil</code>.
- password:  Defaults to <code>nil</code>.
- password_file:  Defaults to <code>nil</code>.
- secure:  Defaults to <code>false</code>.
- logging_properties:  Defaults to <code>{}</code>.
- realm_types:  Defaults to <code>{}</code>.

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
- domain_name: 
- terse:  Defaults to <code>false</code>.
- echo:  Defaults to <code>true</code>.
- username:  Defaults to <code>nil</code>.
- password_file:  Defaults to <code>nil</code>.
- secure:  Defaults to <code>false</code>.
- admin_port:  Defaults to <code>4848</code>.

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
- domain_name: 
- terse:  Defaults to <code>false</code>.
- echo:  Defaults to <code>true</code>.
- username:  Defaults to <code>nil</code>.
- password_file:  Defaults to <code>nil</code>.
- secure:  Defaults to <code>false</code>.
- admin_port:  Defaults to <code>4848</code>.

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
- domain_name: 
- terse:  Defaults to <code>false</code>.
- echo:  Defaults to <code>true</code>.
- username:  Defaults to <code>nil</code>.
- password_file:  Defaults to <code>nil</code>.
- secure:  Defaults to <code>false</code>.
- admin_port:  Defaults to <code>4848</code>.

## glassfish_library

### Actions

- add:  Default action.
- remove: 

### Attribute Parameters

- url: 
- library_type:  Defaults to <code>"common"</code>.
- upload:  Defaults to <code>true</code>.
- domain_name: 
- terse:  Defaults to <code>false</code>.
- echo:  Defaults to <code>true</code>.
- username:  Defaults to <code>nil</code>.
- password_file:  Defaults to <code>nil</code>.
- secure:  Defaults to <code>false</code>.
- admin_port:  Defaults to <code>4848</code>.

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


## glassfish_mq_destination

### Actions

- create:  Default action.
- destroy: 

### Attribute Parameters

- destination_name: 
- queue: 
- config:  Defaults to <code>{}</code>.
- host: 
- port: 
- username:  Defaults to <code>"imqadmin"</code>.
- passfile: 

## glassfish_property

### Actions

- set:  Default action.

### Attribute Parameters

- key: 
- value: 
- domain_name: 
- terse:  Defaults to <code>false</code>.
- echo:  Defaults to <code>true</code>.
- username:  Defaults to <code>nil</code>.
- password_file:  Defaults to <code>nil</code>.
- secure:  Defaults to <code>false</code>.
- admin_port:  Defaults to <code>4848</code>.

## glassfish_resource_adapter

### Actions

- create:  Default action.
- delete: 

### Attribute Parameters

- resource_adapter_name: 
- threadpoolid:  Defaults to <code>nil</code>.
- objecttype:  Defaults to <code>nil</code>.
- properties:  Defaults to <code>{}</code>.
- domain_name: 
- terse:  Defaults to <code>false</code>.
- echo:  Defaults to <code>true</code>.
- username:  Defaults to <code>nil</code>.
- password_file:  Defaults to <code>nil</code>.
- secure:  Defaults to <code>false</code>.
- admin_port:  Defaults to <code>4848</code>.

## glassfish_secure_admin

### Actions

- enable:  Default action.
- disable: 

### Attribute Parameters

- domain_name: 
- terse:  Defaults to <code>false</code>.
- echo:  Defaults to <code>true</code>.
- username:  Defaults to <code>nil</code>.
- password_file:  Defaults to <code>nil</code>.
- secure:  Defaults to <code>false</code>.
- admin_port:  Defaults to <code>4848</code>.

## glassfish_web_env_entry

### Actions

- set:  Default action.
- unset: 

### Attribute Parameters

- webapp: 
- name: 
- type:  Defaults to <code>"java.lang.String"</code>.
- value:  Defaults to <code>nil</code>.
- description:  Defaults to <code>nil</code>.
- domain_name: 
- terse:  Defaults to <code>false</code>.
- echo:  Defaults to <code>true</code>.
- username:  Defaults to <code>nil</code>.
- password_file:  Defaults to <code>nil</code>.
- secure:  Defaults to <code>false</code>.
- admin_port:  Defaults to <code>4848</code>.

# License and Maintainer

Maintainer:: Peter Donald (<peter@realityforge.org>)

License:: Apache 2.0
