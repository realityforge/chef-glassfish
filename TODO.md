# TODO

This file documents basic tasks that still need completion.

* Used cached properties in all of the resource providers. Mark prefixes of properties that are created as
  unknown and then do a comparison at the end to make sure glassfish cookbook has checked all the corner cases.
* Currently admin objects and jms resources contend. If you define admin resources then
  the jms resource list may delete them and vice-versa.
* Update LWRPs so that they will update resource configuration when input config changes.
  - connector-connection-pool
  - admin_object
  - resource-adapter
  - web-env-entry
  - jms_resource
  - connector_resource
  - javamail_resource
* Add LWRPs to manage the http-listener and protocol settings.
* Add LWRPs to manage the JMS server configuration.
* In GlassFish 4 supply deployment order for all deployables - derive it from existing priority. Make sure it is updated at runtime via deployment-order.
* Add some mechanism for more reasonable production ready templates
  - See http://alexandru-ersenie.com/tag/glassfish-multiple-domains/
* Add mechanism for updating or removing specific modules. i.e.
  - Remove updater

    file "#{node['glassfish']['base_dir']}/glassfish/modules/console-updatecenter-plugin.jar" do
      action :delete
    end

  - Update the version of jersey or metro or jfs implementation.
