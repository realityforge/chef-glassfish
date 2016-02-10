#
# Copyright Peter Donald
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

#<> GlassFish User: The user that GlassFish executes as.
default['glassfish']['user'] = 'glassfish'
#<> GlassFish Admin Group: The group allowed to manage GlassFish domains.
default['glassfish']['group'] = 'glassfish-admin'

#<> Version: The version of the GlassFish install package.
default['glassfish']['version'] = '4.0'
#<> variant: The variant of the GlassFish install package. Usually payara or glassfish.
default['glassfish']['variant'] = 'glassfish'
#<> Package URL: The url to the GlassFish install package.
default['glassfish']['package_url'] = nil
#<> GlassFish Base Directory: The base directory of the GlassFish install.
default['glassfish']['base_dir'] = '/usr/local/glassfish'
#<> GlassFish Install Directory: The directory into which glassfish is actually installed.
default['glassfish']['install_dir'] = nil
#<> A flag determining whether we should remove the domains directory.
default['glassfish']['remove_domains_dir_on_install'] = true
#<> GlassFish Domain Directory: The directory containing all the domain instance data and configuration.
default['glassfish']['domains_dir'] = '/srv/glassfish'
#<> GlassFish Domain Definitions: A map of domain definitions that drive the instantiation of a domain.
default['glassfish']['domains'] = Mash.new
#<> Asadmin Timeout: The timeout in seconds set for asadmin calls
default['glassfish']['asadmin']['timeout'] = 150

#<> Extract libraries for the OpenMQ Broker: A list of URLs to jars that are added to brokers classpath.
default['openmq']['extra_libraries'] = Mash.new
#<> GlassFish OpenMQ Broker Definitions: A map of broker definitions that drive the instantiation of a OpenMQ broker.
default['openmq']['instances'] = Mash.new
#<> GlassFish OpenMQ Broker Directory: The directory containing all the broker instance data and configuration.
default['openmq']['var_home'] = '/var/omq'
