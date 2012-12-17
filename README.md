Description
===========

[![Build Status](https://secure.travis-ci.org/realityforge/chef-glassfish.png?branch=master)](http://travis-ci.org/realityforge/chef-glassfish)

The glassfish cookbook installs and configures the GlassFish application server and the OpenMQ message broker bundled
with the GlassFish application server. The cookbook also defines resources to create and configure GlassFish
application domains and OpenMQ broker instances. There are also two recipes (`glassfish::attribute_driven_domain` and
`glassfish::attribute_driven_mq`) that look for attributes defined on the current node that will drive the creation of
GlassFish application domains or OpenMQ broker instances. See the attribute_driven_mq and attribute_driven_domain
sections below for a description of the attribute definitions.

Requirements
============

* `java` cookbook
* `authbind` cookbook
* `cutlery` cookbook

Tested on Ubuntu 11

Attributes
==========

* `node['glassfish']['user']` - The user that executes the service. Defaults to "glassfish".
* `node['glassfish']['user']` - The group of the user that executes the service. Defaults to "glassfish-admin".
* `node['glassfish']['package_url']` - The url to the glassfish package.
* `node['glassfish']['base_dir']` - The base directory into which GlassFish is installed. Defaults to "/usr/local/glassfish-3.1.2".
* `node['glassfish']['domains_dir']` - The directory in which the GlassFish domains are stored. Defaults to "/usr/local/glassfish-3.1.2/glassfish/domains".
* `node['glassfish']['domains']` - A map that describes zero or more GlassFish application domains. Used to drive the `attribtue_driven_domain` recipe.
* `node['openmq']['instances']` - A map that describes zero or more message broker instances. Used to drive the `attribtue_driven_mq` recipe.
* `node['openmq']['extra_libraries']` - A has of URLs to jars to place on the OpenMQ classpath.
* `node['openmq']['var_home']` - The directory in which the OpenMQ instances are stored. Defaults to "/var/omq".

Usage
=====

There are three recipes provided:

* `glassfish::default` - Install the GlassFish binaries.
* `glassfish::attribute_driven_domain` - Invokes the `glassfish::default` recipe to install the glassfish binaries and
  then creates 0 or more GlassFish application domains based on attribute values defined on the node.
* `glassfish::attribute_driven_mq` - Invokes the `glassfish::default` recipe to install the glassfish binaries and
  then creates 0 or more OpenMQ message broker instances based on attribute values defined on the node.


GlassFish Domain Resources
==========================

Several of the resources defined in the cookbook relate to a GlassFish application domain. The resource is typically
responsible for communicating with the domain or creating the domain so that it can be communicated with remotely. As
a result there are several attributes that are common across all of the domain resources;

### Common Attribute Parameters

- domain_name: the name of the domain.
- terse: Use terse output from the underlying asadmin. Defaults to true.
- echo: Echo commands supplied to asadmin. Defaults to false.
- username: Username to use when communicating with the domain. Defaults to nil.
- password_file: the file in which the password must be stored assigned to appropriate key. Must be set if username is set. Defaults to nil.
- secure: If true use SSL when communicating with the domain for administration. Defaults to false.
- admin_port: the port on which the web management console is bound. Defaults to 4848.

`glassfish_domain`
------------------

Creates a GlassFish application domain, creates an OS-level service and starts the service.

### Actions

- :create: Create the domain, enable and start the associated service.
- :destroy: Stop the associated service and delete the domain directory and associated artifacts.

### Attribute Parameters

- max_memory: The amount of heap memory to allocate to the domain in MiB. Defaults to 512.
- max_perm_size: The amount of perm gen memory to allocate to the domain in MiB. Defaults to 96.
- max_stack_size: The amount of stack memory to allocate to the domain in KiB. Defaults to 128.
- port: the port on which the HTTP service will bind. Defaults to 8080.
- extra_libraries: an array of URLs of libraries that should be added to the domains classpath.
- extra_jvm_options: an array of extra arguments to pass the JVM. Defaults to [].
- env_variables: A hash of environment variables set when running the domain. Defaults to {}.
- logging_properties: a hash of properties that will be merged into logging.properties. Use this to send logs to
  syslog or graylog.
- realm_types: an map of names to realm implementation classes that is merged into the default realm types.
- domain_name: the name of the domain. This is the name of the resource.
- password: Password to use when communicating with the domain. Must be set if username is set. Defaults to nil.
- password_file: the file in which the password is saved. Should be set if username is set. Defaults to nil.
- All of the common attribute parameters.

### Example

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
        "gelf4j.logging.GelfHandler.defaultFields" => '{"environment": "' + node.chef_environment + '", "facility": "MyDomain"}',
        "gelf4j.logging.GelfHandler.compressedChunking" => false,
      }
    end

`glassfish_asadmin`
-------------------

`asadmin` is the command line application used to manage a GlassFish application server. Typically this resource is
used when there is not yet a resource defined in this cookbook for executing an underlying command on the server.

### Actions

- :run: Execute the command.

### Attribute Parameters

- command: the command to execute. This is the name of the resource.
- All of the common attribute parameters.

### Example

    # List all the domains on the server
    glassfish_asadmin "list-domains" do
       domain_name 'my_domain'
    end

`glassfish_secure_admin`
-------------------

Enable or disable secure admin flag on the glassfish server which enables/disables remote administration.

### Actions

- :enable: Enable remote access/secure admin.
- :disable: Disable remote access/secure admin.

### Example

    glassfish_secure_admin "My Domain Remote Access" do
       action :enable
    end

`glassfish_web_env_entry`
-------------------------

Set a value that can be retrieved as a `web env entry` in a particular web application. This resource is idempotent and
will not set the entry if it already exists and has the same value. Nil values can be specified. The java type of the
value must also be specified.

### Actions

- :set: Set the value as entry.
- :unset: Remove the entry.

### Attribute Parameters

- webapp: the name of the web application name.
- name: the key name of the web env entry.
- value: the value of the entry. May be nil.
- type: the java type name of env entry. Defaults to "java.lang.String".
- description: a description of the entry.
- All of the common attribute parameters.

### Example

    # List all the domains on the server
    glassfish_web_env_entry "Set IntegrationServerURL" do
       domain_name 'my_domain'
       name 'IntegrationServerURL'
       value 'http://example.com/Foo'
       type 'java.lang.String'
    end

`glassfish_auth_realm`
----------------------

TODO

`glassfish_custom_resource`
---------------------------

TODO

`glassfish_deployable`
----------------------

TODO

`glassfish_jdbc_connection_pool`
--------------------------------

TODO

`glassfish_jdbc_resource`
-------------------------

TODO

`glassfish_resource_adapter_config`
--------------------------------

TODO

`glassfish_property`
--------------------

TODO

OpenMQ Message Broker Resources
===============================

Several of the resources defined in the cookbook relate to a OpenMQ message broker. These are listed below

`glassfish_mq`
--------------

Creates a OpenMQ message broker instance, creates an OS-level service and starts the service.

### Actions

- :create: Create the message broker instance, enable and start the associated service.
- :destroy: Stop the associated service and delete the instance directory and associated artifacts.

### Attribute Parameters

- max_memory: The amount of heap memory to allocate to the domain in MiB. Defaults to 512.
- max_stack_size: The amount of stack memory to allocate to the domain in KiB. Defaults to 128.
- port: the port for the portmapper to bind. Defaults to 7676.
- admin_port: the port on which admin service will bind. Defaults to 7677.
- jms_port: the port on which jms service will bind. Defaults to 7678.
- stomp_port: the port on which the stomp service will bind. If not specified, no stomp service will execute. Defaults to nil.
- jmx_port: the port on which jmx service will bind. If not specified, no jmx service will be exported. Defaults to nil.
- jmx_admins: A map of username to password for read-write JMX admin interface. Ignored unless jmx_port is specified.
- jmx_monitors: A map of username to password for read-only JMX admin interface. Ignored unless jmx_port is specified.
- logging_properties: a hash of properties that will be merged into logging.properties. Use this to send logs to
  syslog or graylog.
- config: A map of key-value properties that are merged into the OpenMQ configuration file.
- users: a map of users to passwords for interacting with the service.
- admin_user: The user in the users map that is used during administration. Defaults to 'imqadmin'.
- queues: A map of queue names to queue properties.
- topics: A map of topic names to topic properties.
- access_control_rules: An access control list of patterns to users.

### Example

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

`glassfish_mq_destination`
-----------------------

Creates or deletes a queue or a topic in an OpenMQ message broker instance.

### Actions

- :create: Create the destination.
- :destroy: Destroy the destination.

### Attribute Parameters

- destination_name: The name of the destination. The name of the resource.
- queue: True if the destination is a node, false for a topic.
- config: The configuration settings for queue. Valid properties include those exposed by JMX. Also supports the key
          'schema' containing a URL which expands to 'validateXMLSchemaEnabled=true' and 'XMLSchemaURIList=$uri'.
- host: The host of the OpenMQ message broker instance.
- port: The port of the portmapper service in message broker instance.
- username: The username used to connect to message broker. Defaults to 'imqadmin'.
- passfile: The filename of a property file that contains a password for admin user set using the property "imq.imqcmd.password".

### Example

    # Create a queue destination
    glassfish_destination "MySystem.MyMessageQueue" do
      queue true
      config {'schema' => 'http://example.org/MyMessageFormat.xsd'}
      host "localhost"
      port 7676
      username 'imqadmin'
      passfile '/etc/omq/omqadmin.pass'
    end


attribute_driven_domain
=======================

The `attribute_driven_domain` recipe interprets attributes on the node and defines the resources described in the
attributes.

### Example

TODO

attribute_driven_mq
===================

The `attribute_driven_mq` recipe interprets attributes on the node and defines the resources described in the
attributes.

### Example

TODO
