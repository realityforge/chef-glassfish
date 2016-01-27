[![Build Status](https://secure.travis-ci.org/realityforge/chef-glassfish.png?branch=master)](http://travis-ci.org/realityforge/chef-glassfish)

The glassfish cookbook installs and configures the GlassFish application server and the OpenMQ message broker bundled
with the GlassFish application server. The cookbook also defines resources to create and configure GlassFish
application domains and OpenMQ broker instances.

**NOTE**: If using chef client 12.5 or later then you will need to include the `compat_resource` cookbook as the
chef client changed the resource API between versions 12.4 and 12.5. If you are using chef-server then it is necessary
that the cookbook is uploaded to the server. A simpler solution may be to create a wrapper cookbook that depends on
both the `glassfish` and `compat_resource` cookbooks.

A sample project with a Vagrantfile that launches a glassfish instance is available in [chef-glassfish-example](https://github.com/realityforge/chef-glassfish-example) project.
