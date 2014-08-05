# TODO

This file documents basic tasks that still need completion.

* Update jms_resource so that it will set properties when the jms property has changed.
* Add LWRPs for the EE7 concurrency resources. These possibly include;
  - Context Services
  - Managed Thread Factories
  - Managed Executor Services
  - Managed Scheduled Executor Services
* Add LWRPs to manage the http-listener and protocol settings.
* Add LWRPs to manage the JMS server configuration.
* In GlassFish 4 supply deployment order for all deployables - derive it from existing priority. Make sure it is updated at runtime via deployment-order.
* Howto: set server.ejb-container.property.disable-nonportable-jndi-names="true"
* Add some mechanism for more reasonable production ready templates
  - See http://alexandru-ersenie.com/tag/glassfish-multiple-domains/
* Add mechanism for updating or removing specific modules. i.e.
  - Remove updater

    file "#{node['glassfish']['base_dir']}/glassfish/modules/console-updatecenter-plugin.jar" do
      action :delete
    end

  - Update the version of jersey or metro or jfs implementation.

