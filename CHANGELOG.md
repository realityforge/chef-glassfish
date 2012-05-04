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