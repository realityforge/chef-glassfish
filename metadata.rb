name             'glassfish'
maintainer       'Peter Donald'
maintainer_email 'peter@realityforge.org'
license          'Apache 2.0'
description      'Installs/Configures GlassFish Application Server'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.5.24'

recipe 'glassfish::default', 'Installs the GlassFish binaries.'
recipe 'glassfish::attribute_driven_domain', 'Configures 0 or more GlassFish domains using the glassfish/domains attribute.'
recipe 'glassfish::search_driven_domain', 'Configures 0 or more GlassFish domains using search to generate the configuration.'
recipe 'glassfish::attribute_driven_mq', 'Configures 0 or more GlassFish OpenMQ brokers using the openmq/instances attribute.'

supports 'ubuntu'

depends 'java'
depends 'authbind'
depends 'cutlery', '~> 0.1'

attribute 'glassfish/user',
  :display_name => 'GlassFish User',
  :description => 'The user that GlassFish executes as',
  :type => 'string',
  :default => 'glassfish'

attribute 'glassfish/group',
  :display_name => 'GlassFish Admin Group',
  :description => 'The group allowed to manage GlassFish domains',
  :type => 'string',
  :default => 'glassfish-admin'

attribute 'glassfish/package_url',
  :display_name => 'URL for GlassFish Package',
  :description => 'The url to the GlassFish install package',
  :type => 'string',
  :default => 'http://dlc.sun.com.edgesuite.net/glassfish/3.1.2/release/glassfish-3.1.2.zip'

attribute 'glassfish/base_dir',
  :display_name => 'GlassFish Base Directory',
  :description => 'The base directory of the GlassFish install',
  :type => 'string',
  :default => '/usr/local/glassfish'

attribute 'glassfish/domains_dir',
  :display_name => 'GlassFish Domain Directory',
  :description => 'The directory containing all the domain definitions',
  :type => 'string',
  :default => '/usr/local/glassfish/glassfish/domains'

attribute 'glassfish/domains',
  :display_name => 'GlassFish Domain Definitions',
  :description => 'A map of domain definitions that drive the instantiation of a domain',
  :type => 'hash',
  :default => {}

attribute 'openmq/instances',
  :display_name => 'GlassFish OpenMQ Broker Definitions',
  :description => 'A map of broker definitions that drive the instantiation of a OpenMQ broker',
  :type => 'hash',
  :default => {}

attribute 'openmq/extra_libraries',
  :display_name => 'Extract libraries for the OpenMQ Broker',
  :description => 'A list of URLs to jars that are added to brokers classpath',
  :type => 'hash',
  :default => {}
