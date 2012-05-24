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
