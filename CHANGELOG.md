## v1.2.7:
* Enhance : Add support for Payara 5.2021.10

## v1.2.6:
* Fix : Fix thread pool comparison in attribute driven domain

## v.1.2.5:
* Fix : Revert Azul JDK specific JVM options from 1.2.2
* Enhance : Improve JVM option parsing

## v.1.2.3 - v.1.2.4
* Unreleased

## v.1.2.2:
* Enhance : Better support for Payara 5.194+.

## v.1.2.1:
* Enhance : Add support for newer JVM 8 and Payara.

## v.1.2.0:
* Enhance : Add support for Chef infra client 16

## v.1.1.1:
* Enhance : Add support for Payara 5.192

## v.1.1.0:
* Enhance : Add support for Payara 5.184 and 5.191

## v.1.0.2:
* Enhance : Improve systemd restarting on failure
* Enhance : Wait for Glassfish admin to be ready before adding a library

## v1.0.1:
* Fix     : Bugfix release to not change mode, owner or group of /usr/local

## v1.0.0:
* Enhance : Add support for Payara 5.183
* Enhance : Add Windows support
            Huge thanks to Akos Vandra @axos88 for work on this!
* Enhance : Moved waiting for Glassfish to be up to library
* Enhance : Use Mixlib::ShellOut for calling commands
* Enhance : Add support for specifying self-signed certificate CN

## v0.8.0:
* Enhance : Add support to Payara 5.182
* Fix     : Fix Cookstyle issues
* Change  : Rename is_property_cache_present to property_cache_present
* Enhance : Remove dependency of compat_resource cookbook (Works only on Chef 13 or above)
* Change  : Rename glassfish_web_env_entry name to glassfish_web_env_entry_name
* Enhance : Improvements based on Cookstyle and Foodcritic
* Enhance : Add initial support for Payara 5.181
* Change  : Drop support for Chef 12
* Change  : Avoid specifying the user and group when executing asadmin commands if
            on the windows platform. Submitted by Akos Vandra.
* Fix     : Start using the execute resource rather than the bash resource in preparation
            for supporting windows. Submitted by Akos Vandra.
* Fix     : Make sure all the timeouts use the node attribute `node['glassfish']['asadmin']['timeout']`
            rather than hardcoding a specific value. Submitted by Akos Vandra.
* Fix     : Restore support for multiple instances of GlassFish under ubuntu.
            Fix submitted by Tero Pihlaja.
* Enhance : Generate `bin/<instance>_imqcmd` script to ease interacting from the
            command line with the installed broker.
* Enhance : Avoid re-touching OpenMQ log each chef converge.
* Enhance : Enables Glassfish instances defined in the domain attributes. Fixes #77.
            Submitted by David Lakatos.
* Enhance : Add support for defining JMS Destinations. Submitted by James Walker.
* Enhance : Add support for Payara 4.1.1.161. Submitted by Ian Caughley.
* Bug     : Make sure thread pools that are not configured are correctly deleted.
            Fixes #88. Reported by David Lakatos.
* Bug     : Fix directory permissions on archives directory. Fixes #80.
            Reported by David Lakatos.
* Bug     : Support -1 as value for numeric attributes in jdbc_connection_pool. Fixes #74.
            Reported by David Lakatos.
* Enhance : Add the ability to disable deletion/undeploying/unsetting of elements in
            `attribute_driven_domain` receipe by adding an attribute 'managed' set to
            false in the top level of the element. i.e. To disable undeploying of
            applications then add configuration such as:

                'deployables' => {
                        'managed' => false
                    },
* Change   : Updated login.conf for Glassfish 4. Submitted by Ian Caughley.
* Enhance  : Let the cookbook define systemd start/stop timeouts. Fixes #93.
             Submitted by David Lakatos.
* Change   : Update the url to download GlassFish packages from from dlc.sun.com.edgesuite.net
             to download.java.net
* Fix      : Fixed creation of Managed Schedule Exector Services. Submitted by Ian Caughley.

## v0.7.6:
* Enhance : Generate `asenv.conf` with correct values in case the asadmin command is used
            directly and not from the init scripts or using the generated script.
* Enhance : Makes application library usage available for deployables stored in
            ${com.sun.aas.instanceRootURI}/lib/applibs
* Enhance : Enables the installation of binary endorsed library jar files. For more details, see
            https://docs.oracle.com/cd/E26576_01/doc.312/e24930/class-loaders.htm#GSDVG00097
            Submitted by David Lakatos.
* Enhance : Enables setting asadmin timeout Submitted by David Lakatos.
* Change  : Depend upon the `compat_resource` cookbook if present. This is required for
            Chef 12.5+ as chef client changed the resource API between 12.4 and 12.5.
            Change was inspired by Tero Pihlaja. This stops the cookbook working in
            Chef 11 and earlier.
* Bug     : Connector archive deployment was preceded by its configuration. Fix by reordering
            rar deployables prior to resource adapter definition. Fixed by David Lakatos.
* Bug     : java.endorsed.dirs variable corrected in domain.rb resource: Fixes #65.
            Submitted by David Lakatos.

## v0.7.4:
* Change  : Added support for portbase in the domain creation command.
* Bug:    : Fix handling of description attribute in `connector_connection_pool` lwrp.
* Bug:    : Fix bug where defaulting value for master_password could allow a password
            under 6 characters that will no work with later versions of Payara/GlassFish.
* Enhance : Support rmi_port attribute on `mq` resource so jmx rmi port can be a fixed
            number and thus possible to pass through firewall rules.
* Enhance : Support arrays of users for access control rules of `mq` resource.
* Enhance : Add support for Payara 4.1.1.154.
* Enhance : Support deploying glassfish with zero deployables.
* Bug:    : Work around bugs in GlassFish 3.1.2.2 with `jvm_options` LWRP.
* Change  : Move the broker configuraiton of destinations, users, and access control
            rules below the instance key rather than at top level of mq configuration.

## v0.7.2:
* Enhance : Remove runit and and upstart as supported init styles. Largely due to
            problems getting GlassFish to in Payara releases simultaneously with
            GlassFish releases is difficult when the cookbook reaches into the
            innards of glassfish.
* Enhance : Guess the type of `custom_resource` values based on the ruby value.
* Enhance : Add support for Payara 4.1.151 and 4.1.152.
* Bug     : Correct the mechanisms for setting JVM properties.
* Enhance : Speed up several resources by caching properties and checking properties
            prior to performing actions.

## v0.6.4:
* Enhance : Initial support for deploying Payara 4.1.144 rather than the Oracle
            branded GlassFish.
* Enhance : Set the default `node['glassfish']['package_url']` to nil and attempt
            to derive the package url in the default.rb recipe. The url is derived
            based on the specified version.
* Enhance : Add an attribute describing the install variant (Payara or GlassFish).
* Enhance : Add timeouts to all the bash resources, including the only_if and not_if
            checks. This avoids the scenario where a hung GlassFish results in a hung
            chef run.

## v0.6.2:
* Change  : Check multiple urls to ensure glassfish is up and add a wait after the
            check. This attempts to ensure that the admin console is correctly
            initialized prior to accessing it in other resources.
* Bug     : Fix the secure_admin LWRP so that it works, even when the secure flag is
            set for the domain.
* Enhance : Later versions of Java 7 and Java 8 require that keystore passwords
            are greater than 6 characters. If a domain's `master_password` is under
            6 characters then the creation of a domain would silently fail to create
            the keystore and then the 'enable-secure-admin' resource would fail. If
            the `master_password` is unspecified then the `password` attribute for
            the domain must be 6 characters or more. This is now enforced by raising
            an exception during domain creation if the password is not long enough.
* Bug     : Ensure undeploy action of the glassfish_deployable resource correctly
            correctly matches against deployable's name in the only_if guard.
            Submitted by sshapoval.
* Enhance : Under debian default the init style to runit.
* Bug     : Ensure that the grep in the guards used when determining whether to
            create/update resources do not treat values as special grep characters.
* Bug     : Stop using versions in names of deployables as several bugs within
            GlassFish are triggered by this feature. In particular this includes
            bugs in the concurrency, batch and SOAP libraries. This results in
            versions of the artifacts being stored on the filesystem.
* Bug     : Don't attempt to create user if system_user for glassfish domain is
            set to root.
* Enhance : Explicitly support master_password configuration for a glassfish
            domain.
* Change  : Add a configuration property `node['glassfish']['remove_domains_dir_on_install']`
            that controls whether the domains directory is removed when glassfish
            version is upgraded or initially installed.
* Change  : Avoid custom domain.xml and use domain.xml files supplied by
            glassfish.
* Bug     : Rework jms_resources and connector related resources so that
            the resources defined in each section will not contend.
* Bug     : Fix compatibility with later versions of Chef 11.
* Bug     : Fix bug with attribute_driven_domain recipe so that boolean
            `custom_resources` with a false value are not deleted at the end
            of a converge.
* Bug     : Fix the ssl bug so that domain without remote_access can be deployed.
* Enhance : Use the archive cookbook to retrieve the glassfish package. Use the
            `node['glassfish']['install_dir']` configuration property to get at
            base directory of version.
* Enhance : Add default-web.xml template to support deploying glassfish 4.1.
* Bug     : Avoid recreating jms resources every run. Reported by Karsten Planz.
* Enhance : Add RealityForge::GlassFish helper class and record the "current"
            glassfish domain and broker instance in the attribute-driven recipes.
* Bug     : Fix bug in domain specific asadmin script so that parameters are
            passed through as is.
* Enhance : Include a default-web.xml that turns off the xpowerdBy flag for the
            jsp servlet.
* Enhance : Increase the default stack of the glassfish domain so that it works
            on later versions of 64-bit Java 7.

## v0.6.0:
* Enhance : Avoid some warnings from asadmin that are internal glassfish4 issues.
* Enhance : Add LWRPs to manage concurrency resources within GlassFish 4.
* Enhance : Add iiop_listener LWRP to manage the iiop-listeners within GlassFish.
* Bug     : Ensure thread-pools that are not part of the configuration are
            deleted.
* Change  : Default to installing GlassFish 4.0.

## v0.5.30:
* Enhance : Add thread_pool LWRP to manage the thread-pools within GlassFish.
            Ensure it is correctly called attribute_driven_domain recipe.
* Bug     : Only delete the index.html in docroot during install, not
            every converge.
* Enhance : Recursively create omq runtime directory.
* Enhance : Ensure auth_realm properties are updated if changed after initial
            creation.
* Enhance : Initial support for RHEL by using a custom upstart script.
            Submitted By Jim Dowling.
* Enhance : Support using 'root' as the system user. Submitted By Mike Thomas.
* Enhance : Improve mechanism for accessing version to be portable to older
            versions of ruby. Submitted By Mike Thomas.
* Enhance : Improve documentation for the attribute driven recipe. Submitted
            by Mike Thomas.
* Enhance : Support `requires_restart` parameter on the glassfish_library
            LWRP. Submitted by Mike Thomas.
* Change  : Set the unask to 0022 to allow logstash and other applications
            access to the generated logs. Submitted by Gert Leenders.
* Enhance : Rework the glassfish_secure_admin functionality to be more
            resilient regardless of the init_style and version of
            glassfish in use.
* Enhance : Support runit as an init style.
* Enhance : Work around some warnings issued by GlassFish 4 install.
* Enhance : Initial support for GlassFish 4.
* Enhance : Add significantly more logging to help debugging issues.
* Bug     : Fix permission on glassfish home directory so that the
            .asadmintruststore file can be created.
* Change  : Set the default stack size to 250 in mq broker LWRP so that
            the LWRP works without specifying a value under Java 7 x64
            systems.
* Enhance : Support init_style on glassfish_mq LWRP. Add initial support
            for runit.

## v0.5.28:
* Change  : Remove version specifier in cutlery dependency constraint as it
            can trigger a bug in Chef 11's dependency resolver.
* Bug     : Relax some permissions on directories and files downloaded
            from remote sources to allow group access as the way Vagrant
            maps the cache directory means that the user can be modified
            to vagrant. Suggested by Martin Algesten.
* Bug     : Support non-string "value" parameters in `attribute_driven_domain`
            for `custom_resource` elements and `web_env_entries` elements.
* Enhance : Sort elements within the `attribute_driven_domain` recipe in each
            section by a priority field if present. The default priority
            is 100 if unspecified.
* Change  : Convert hooks for including recipes in the
            `attribute_driven_recipe` from being an array of recipes
            to a hash where the key is the recipe name. Improves the
            interoperability with deep merges.
* Enhance : Ensure that the parameters of the `glassfish_jdbc_connection_pool`
            LWRP and the `glassfish_jdbc_resource` are updated even if the
            resource exists.
* Bug     : Enable the Glassfish domain service aswell as starting it.
* Enhance : Remove domains in the `attribute_driven_domain` recipe
            when there is no longer any configuration to represent
            domain.
* Enhance : Add the before and after hooks for the deployable element
            in the `attribute_driven_domain` recipe.
* Bug     : Ensure that the 'min_memory' config value on the glassfish
            domain is reflected from the configuration onto the domain
            LWRP in the `attribute_driven_domain` recipe.
* Bug     : Rework the destroy action on the `glassfish_domain` LWRP to
            avoid invoking the asadmin command and potentially failing
            if the domain is in an inconsistent state.
* Bug     : Ensure that libraries cached copy is unique per domain to avoid
            scenario where file can be owned by a different domain.
* Enhance : Support the specification of different system users for each
            glassfish domain in all the LWRPs and the
            `attribute_driven_domain` recipe.
* Change  : Default the 'glassfish/domains_dir' attribute to /srv/glassfish.
* Bug     : Fix configuration of `factoryclass` parameter on
            `glassfish_custom_resource` in `attribute_driven_domain` recipe.
            Submitted by Ian Caughley.
* Bug     : Fix allowable values of `transactionsupport` parameter to include
            `XATransaction` rather than ` XATransaction` in
            `glassfish_connector_connection_pool`.
* Bug     : Fix for glassfish\_domain resource sourcing template from cookbook
            where it is used.
* Bug     : Added mq\_ensure\_running resource to replace upstart check which
            was causing issues on IPv6 enabled hosts. ~ Jordan Hagan
* Bug     : Consistency fix for attributes used to generate password hash in
            OpenMQ passwd file.

## v0.5.24:
* Bug     : Fix the `attribute_driven_domain` to avoid undeploying OSGi deployables every second run.
* Change  : Append versions to the name of OSGi components rather than storing the version on the
            file system in a file.
* Enhance : Don't require the url parameter in the `glassfish_deployable` LWRP as it is only required
            for the deploy action.
* Enhance : Add the ability to hook into the configuration of domains in `attribute_driven_domain` recipe
            by adding recipes to include before and after a domain is configured.
* Bug     : Stop trying to undeploy non-existent resources when server is not upa at start of chef run.

## v0.5.22:
* Change  : Replace the use of cutlery's notifying_action with Chef 11's use_inline_resources method.
* Bug     : Ensure that changes to custom resources are updated on the glassfish server if required.

## v0.5.20:
* Bug     : Ensure terse and echo flags are correctly passed to asadmin command.
* Fix     : Ensure that alternative domain paths are supported.
* Change  : Prefer new notification syntax.
* Change  : Avoid downloading remote artifacts (deployables, libraries and base install) if they will not
            actually be used by adding some not_if guards.

## v0.5.18:
* Change  : Attempting to redeploy the glassfish server in to a directory while an existing service is currently
            running results in an error in usermod "usermod: user glassfish is currently logged in". Change the
            default attributes for the home directory so that glassfish is always installed to a fixed location
            to avoid this scenario in the future.
* Change  : Support file:// urls in `glassfish_deployable` LWRP.
* Change  : Avoid checking for port availability when creating the domain.
* Change  : Rework the deployable so that the non-osgi components will store the version information as part
            of the name. This avoids the scenario where redeploying the same application with a different
            version could undeploy the existing application but fail to deploy the new version. The new approach
            will enable the old version only when the new deployable successfully deploys.

## v0.5.16:
* Change  : Stop using LWRPs to gather the scan the list of resources to delete in the `attribute_driven_domain`
            recipe and instead execute the code inline. Refactor the asadmin library to make it easier to
            implement this functionality.

## v0.5.14:
* Change  : Extract the utility code out into the 'cutlery' cookbook.

## v0.5.12:
* Bug     : Fix regression where properties were not escaping the ':' or '=' characters correctly.

## v0.5.10:
* Enhance : Set umask to 0700 for services.
* Enhance : Escape a more complete set of shell characters when escaping properties. Identified by Robin Wenglewski.
* Change  : Support specification of the library_type in the extra_libraries section while evaluating the
            `attribute_driven_domain` recipe. Submitted by Robin Wenglewski.
* Change  : Make glassfish user a system user.
* Bug     : Ensure all services have the status flag enabled.
* Bug     : Stop starting the glassfish service multiple times in the `glassfish_domain` LWRP and remove duplicate
            actions that caused issues in later versions of chef and how it interacted with upstart services.
* Change  : Upgrade to the 3.1.2.2 version of Glassfish. There was several crippling bugs in the 3.1.2 version.
* Bug     : Fix the guard in the `glassfish_property` LWRP so it will not execute if not needed.
* Bug     : Fix bug that prevented the deletion of historic web_env_entries.
* Bug     : Fix bug due to looking for web_env_entries in osgi deployables. Resulted in errors in glassfish log.
* Bug     : Ensure that the sort key if any is passed to the blend_search_results_into_node method
* Bug     : Avoid attempting to delete the list file if it does not exist. Bug can be expressed when glassfish is
            installed but not running or the domain does not exist.
* Enhance : Add some default JVM options. (-Dfile.encoding=UTF-8 and -Djava.awt.headless=true)
* Enhance : Default to not setting the server name in HTTP response by defaulting the product.name system property.
* Enhance : Expand the realm_types parameter of the domain to support chained configs, flags options in configuration.

## v0.5.8:

* Change  : Remove extra_libraries parameter from the `glassfish_domain` LWRP and replace it's use in the
            `attribute_driven_domain` recipe with uses of the `glassfish_library` LWRP.
* Enhance : Add a `glassfish_library` LWRP that can add and remove libraries of various types to the instance.
* Change  : Update the `attribute_driven_domain` recipe to use the keys;
            - 'admin_objects' rather than 'admin-objects'
            - 'jaas_context' rather than 'jaas-context'
            - 'assign_groups' rather than 'assign-groups'
* Enhance : Update the `glassfish_secure_admin` LWRP to immediately restart the service if invoked.
* Enhance : In the `attribute_driven_domain` recipe, delete sub-components that are no longer present in the node
            configuration. The sub-components include things such as resources, realms, pools, deployables etc.
* Bug     : Ensure that the delete action on the `glassfish_custom_resource` LWRP actually executes.
* Enhance : Add returns parameter to the `glassfish_asadmin` LWRP that is directly applied to underlying bash resource.
* Enhance : Pass through the ignore_failure flag on the `glassfish_asadmin` resource to the underlying resource.
* Enhance : Add in a `search_driven_domain` recipe to simplify the collection of data for the
            `attribute_driven_domain` recipe.
* Change  : Make jaas_context optional in the `glassfish_auth_realm` LWRP. Submitted By Adrian Stanila.
* Change  : Use default_action DSL rather than constructor to specify default actions for LWRPs. This means the plugin
            requires Chef v0.10.10 or higher.
* Bug     : Fix the usage of the enabled flag in several resource centric LWRPs. Submitted By Adrian Stanila.
* Bug     : Fix the usage of the debug flag in the javamail resource LWRP.
* Bug     : Fix the usage of the target flag in several resource centric LWRPs. Ensure the guard conditions pass the
            correct target flag. Submitted By Adrian Stanila.
* Bug     : Remove obsolete target flag from jdbc_connection_pool, connector_connection_pool, resource_adapter LWRPs.

## v0.5.6:

* Change  : Rename the attribute tree used to define javamail resources in the `glassfish::attribute_driven_domain`
            recipe from `javamail-resources` to `javamail_resources`.
* Change  : Cache the deployable and deployment plan using the 'version' attribute on the `glassfish_deployable`
            LWRP rather than the basename of the URL as the url may not necessarily be unique.
* Enhance : Make the the 'version' attribute on the `glassfish_deployable` LWRP optional and derive it from the url
            if not specified.

## v0.5.5:

* Bug     : Fix the version checking in the `glassfish_deployable` LWRP that had an extra brace.

## v0.5.4:

* Bug     : Revert the default the value of `node['openmq']['extra_libraries']` to be an empty hash as simplifies
            attribute merges and restores compatibility with the v0.0.45 of cookbook.
* Change  : Update the attribute_driven_domain recipe so that domain takes  a hash for the 'extra_libraries'
            configuration to make it easy to merge attribute data from multiple sources.

## v0.5.3:

* Enhance : Add the a LWRP: `glassfish_javamail_resource`.

## v0.5.2:

* Enhance : Ensure non properties are supported in "properties" parameter passed to various resources.
* Enhance : Add the LWRPs: `glassfish_resource_adapter`,`glassfish_connector_resource`, glassfish_admin_object' and
            `glassfish_connector_connection_pool`.

## v0.5.1:

* Change  : Set the rmi hostname to the fully qualified domain name.
* Change  : Force the networking layer to use ipv4 so as not to interfere JMX interoperability.

## v0.5.0:

* Enhance : Support specifying environment variables for the glassfish domain using the attribute driven recipe.
* Change  : Remove the `glassfish_jvm_option` LWRP as the functionality is now provided via the `glassfish_domain` LWRP.
* Enhance : Sort output in configuration files to avoid incorrect service restarts due to non-deterministic ordering.
* Bug     : Replace init.d script with upstart script to eases service management.
* Bug     : Fix failure with mq LWRP's destroy action resulting from incorrect provider specified.

## v0.4.49:

* Bug     : Fix bug introduced in v0.4.48 relating to how the minimum memory is set.
* Enhance : Abort the init script if it fails to start up for "too long" (Currently 60s).

## v0.4.48:

* Change  : Remove the jdbc/__default resource and the associated DerbyPool resource.
* Enhance : Support a minimum memory size when configuring domains.

## v0.4.47:

* Enhance : Add support for configuration of many more parameters for `glassfish_deployable` resource, including
            generation of a deployment plan.
* Enhance : Update resources so that they notify if any of the sub-resources have changed.
* Change  : Rename deployable_key to component_name for the `glassfish_deployable` resource to bring it inline with
            GlassFish documentation.
* Bug     : Fix the documentation for the `glassfish_web_env_entry` resource.
* Bug     : Ensure that the destroy action of the `glassfish_domain` resource runs as the correct user.
* Enhance : Add enable and disable actions to the `glassfish_deployable` resource.
* Enhance : Update the `glassfish_deployable` resource with several new attributes to configure different options
            during deployment.

## v0.4.46:

* Enhance : Support the unset action on the `glassfish_web_env_entry` resource.
* Change  : Convert the following resources to using more strongly typed attributes; `glassfish_web_env_entry`,
            `glassfish_property`, `glassfish_auth_realm`, `glassfish_jdbc_connection_pool`, `glassfish_jdbc_resource`.
* Bug     : Ensure that the glassfish domain is restarted if a a support library is added.
* Change  : Update the `glassfish_jvm_option` resource to support the target attribute.
* Enhance : Support the delete action on the following resources; `glassfish_auth_realm`, `glassfish_custom_resource`,
            `glassfish_jdbc_connection_pool`, `glassfish_jdbc_resource`, `glassfish_jdbc_resource`.
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
