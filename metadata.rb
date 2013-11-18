name             'glassfish'
maintainer       'Peter Donald'
maintainer_email 'peter@realityforge.org'
license          'Apache 2.0'
description      'Installs/Configures GlassFish Application Server'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.5.28'

supports 'ubuntu'

depends 'java'
depends 'authbind'
depends 'cutlery'
recommends 'runit'
