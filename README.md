Description
===========

The glassfish cookbook installs and configures the GlassFish application server and the OpenMQ message broker bundled
with the GlassFish application server. The cookbook also defines resources to create and configure GlassFish
application domains and OpenMQ broker instances. There are also two recipes (`glassfish::attribute_driven_domain` and
`glassfish::attribute_driven_mq`) that look for attributes defined on the current node that will drive the creation of
 GlassFish application domains or OpenMQ broker instances.

Requirements
============

* `java` cookbook
* `authbind` cookbook

Tested on Ubuntu 11

Attributes
==========

* `node['glassfish']['user']` - The user that executes the service. Defaults to "glassfish".
* `node['glassfish']['user']` - The group of the user that executes the service. Defaults to "glassfish-admin".
* `node['glassfish']['package_url']` - The url to the glassfish package.
* `node['glassfish']['package_checksum']` - The SHA256 hash value of package.
* `node['glassfish']['base_dir']` - The base directory into which GlassFish is installed. Defaults to "/usr/local/glassfish3".
* `node['glassfish']['domains_dir']` - The dirextory in which the GlassFish domains are stored. Defaults to "/usr/local/glassfish3/glassfish/domains".
* `node['glassfish']['domains']` - A map that describes zero or more GlassFish application domains. Used to drive the `attribtue_driven_domain` recipe.
* `node['openmq']['instances']` - A map that describes zero or more message broker instances. Used to drive the `attribtue_driven_mq` recipe.
* `node['openmq']['extra_libraries']` - A list of URLs to jars to place on the OpenMQ classpath.

Usage
=====

There are three recipes provided:

* `glassfish::default` - Install the GlassFish binaries.
* `glassfish::attribute_driven_domain` - Invokes the `glassfish::default` recipe to install the glassfish binaries and
  then creates 0 or more GlassFish application domains based on attribute values defined on the node.
* `glassfish::attribute_driven_mq` - Invokes the `glassfish::default` recipe to install the glassfish binaries and
  then creates 0 or more OpenMQ message broker instances based on attribute values defined on the node.


Resource/Provider
=================

GlassFish Domain Resources
--------------------------

Several of the resources defined in the cookbook relate to a GlassFish application domain. The resource is typically
responsible for communicating with the domain or creating the domain so that it can be communicated with remotely. As
a result there are several attributes that are common across all of the domain resources;

### Common Attribute Parameters

- domain_name: the name of the domain.
- terse: Use terse output from the underlying asadmin. Defaults to true.
- echo: Echo commands supplied to asadmin. Defaults to false.
- username: Username to use when communicating with the domain. Defaults to nil.
- password: Password to use when communicating with the domain. Must be set if username is set. Defaults to nil.
- secure: If true use SSL when communicating with the domain for administration. Defaults to false.

`glassfish_domain`
++++++++++++++++++

Creates a GlassFish application domain, creates an OS-level service and starts the service.

### Actions

- :create: Create the domain, enable and start the associated service.
- :destroy: Stop the associated service and delete the domain directory and associated artifacts.

### Attribute Parameters

- max_memory: The amount of heap memory to allocate to the domain in MiB. Defaults to 512.
- max_perm_size: The amount of perm gen memory to allocate to the domain in MiB. Defaults to 96.
- max_stack_size: The amount of stack memory to allocate to the domain in KiB. Defaults to 128.
- port: the port on which the HTTP service will bind. Defaults to 8080.
- admin_port: the port on which the web management console will bind. Defaults to 4848.
- extra_libraries: an array of URLs for libraries that should be added to the domains classpath.
- logging_properties: a hash of properties that will be merged into logging.properties. Use this to send logs to
  syslog or graylog.
- realm_types: an map of names to realm implementation classes that is merged into the default realm types.
- domain_name: the name of the domain. This is the name of the resource.
- All of the domain specific attributes.

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
        "java.util.logging.ConsoleHandler.formatter" => "java.util.logging.SimpleFormatter",
        "gelf4j.logging.GelfHandler.level" => "ALL",
        "gelf4j.logging.GelfHandler.host" => 'graylog.example.org',
        "gelf4j.logging.GelfHandler.defaultFields" => '{"environment": "' + node.chef_environment + '", "facility": "MyDomain"}',
        "gelf4j.logging.GelfHandler.compressedChunking" => false,
      }
    end
