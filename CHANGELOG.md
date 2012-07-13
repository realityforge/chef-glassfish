## v0.0.46:

* Change  : Convert the following resources to using more strongly types attributes;
            `glassfish_property`, `glassfish_auth_realm`, `glassfish_jdbc_connection_pool`
* Bug     : Ensure that the glassfish domain is restarted if a a support library is added.
* Change  : Update the `glassfish_jvm_option` resource to support the target attribute.
* Enhance : Support the delete action on the `glassfish_auth_realm` resource.
* Enhance : Add a `glassfish_secure_admin` resource that either enables or disables remote administration.
* Bug     : Ensure unzip package is installed otherwise the initial install will fail.
* Bug     : Fix bug where a failure during package install could leave the system in an unrecoverable state as the
            partial install directory existed.
* Change  : Use create_if_missing when downloading resources.
* Change  : Disable the xpowered-by header by default.
* Change  : Update the base directory to be specific to the version. i.e. /usr/local/glassfish-3.1.2
* Change  : Update to GlassFish installing 3.1.2 by default.
* Bug     : Stop overriding the log formatter in logging properties files as GlassFish requires a specific formatter.
* Change  : Remove the usage of the `node['glassfish']['package_checksum']` property as the url identifies a fixed version.
* Change  : Explicitly name the cookbook.
* Bug     : Default the value of `node['openmq']['extra_libraries']` to an empty array rather than a hash.

## v0.0.45:

* Change  : Update the GlassFish application server resources to cease the dependence on on attributes and rely on
            parameters passed to the resource.
* Change  : Move the creation of domains directory into the `glassfish_domain` resource.
* Change  : Expand the 'schema' key in MQ destination configurations in the `glassfish_mq_destination` resource rather
            than the `glassfish_mq` resource.
* Change  : The username for the glassfish_mq_destination now defaults to 'imqadmin'.
* Change  : The base directory in which the OpenMQ instances are stored is now retrieved via the
            `node['openmq']['var_home']` property rather than being configured on the resource or in the domain
            definition.
* Enhance : Several changes to the code style of the cookbook and steps to start using foodcritic to check cookbook.
* Enhance : Add some basic documentation to the README.

## v0.0.44:

* Enhance : Support the deployment of OSGi bundles using the 'glassfish_deployable' resource by setting the
            type parameter to ':osgi'. OSGi bundles are deployed prior to the realms or any other commands
             being executed as they can be the modules providing the capability.
* Enhance : Allow the configuration of the set of login modules in the 'glassfish_domain' resource and the
            associated attribute driven recipes.

## v0.0.43:

* Change  : Update the `glassfish_mq` resource so that it is necessary to explicitly specify the jmx admins and
            monitors rather than relying on a search in a 'users' data bag search.

## v0.0.42:

* Change  : Split the managed_domains into two attribute driven recipes. One to create domains and one to create brokers.
* Change  : Change the name of the attribute used to drive the creation of the domains to `glassfish.domains`.

## v0.0.41:

* Change  : Remove the searching of other nodes to locate the OpenMQ topics, queues, users and access control rules as
            that is a business specific policy that has no place in a generic cookbook.

## v0.0.40:

* Enhance : Support the logging_properties attribute on the domain resource and in the managed_domains recipe. This
            makes it possible to configure the logging.properties file generated for the Glassfish application server.

## v0.0.39:

* Enhance : Support the logging_properties attribute being mapped from the managed_domains recipe.

## v0.0.38:

* Enhance : Support the logging_properties attribute on the mq resource. This makes it possible to configure the
            logging.properties file generated for the OpenMQ server.
* Bug     : Explicitly configure the OpenMQ server logging settings. This avoids the scenario where the stomp bridge
            log can grow without bounds.

## v0.0.37:

* Bug     : Stop the OpenMQ server restarting every chef run. Resulting from both the server and the chef rewriting the
            config file. Now chef will only rewrite the file if some of the settings have changed.

## v0.0.36:

* Enhance : Initial convergence of OpenMQ server will no longer require a restart of the server.

## v0.0.35:

* Enhance : Initial convergence of glassfish application server will no longer require a restart if extra libraries are
            specified.

## v0.0.34:

* Change  : Default to supplying the "force" flag during application deployment.
* Bug     : Stop the Glassfish application server restarting when a web env entry or jndi resource is updated.
* Enhance : Enhance the init scripts for the glassfish application server and the openmq server will only return when
            the server is up and listening to expected ports.
* Enhance : Support null values in web env entries.
* Bug     : Fix escaping of string values in custom jndi resources.

## v0.0.32:

* Initial release