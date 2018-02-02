name             'glassfish'
maintainer       'Peter Donald'
maintainer_email 'peter@realityforge.org'
license          'Apache 2.0'
description      'Installs/Configures GlassFish Application Server'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.4.0"

supports 'ubuntu'
supports 'debian'

# Compat resource is required for 12.5+ as resource API changed between 12.4 and 12.5
depends 'compat_resource'

depends 'java'
depends 'authbind'
