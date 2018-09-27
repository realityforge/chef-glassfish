name 'glassfish'
maintainer 'Peter Donald'
maintainer_email 'peter@realityforge.org'
license 'Apache-2.0'
description 'Installs/Configures GlassFish Application Server'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.9.49'

chef_version '>= 13.0' if respond_to?(:chef_version)

issues_url 'https://github.com/realityforge/chef-glassfish'
source_url 'https://github.com/realityforge/chef-glassfish'

supports 'ubuntu'
supports 'debian'
supports 'windows'

depends 'java'
depends 'authbind'
depends 'archive'
depends 'cutlery'
depends 'runit'
depends 'windows'
