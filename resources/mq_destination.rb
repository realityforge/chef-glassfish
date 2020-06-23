#
# Copyright:: Peter Donald
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

# Creates or deletes a queue or a topic in an OpenMQ message broker instance.
#
# @action create Create the destination.
# @action destroy Destroy the destination.
#
# @section Examples
#
#     # Create a queue destination
#     glassfish_destination "MySystem.MyMessageQueue" do
#       queue true
#       config {'schema' => 'http://example.org/MyMessageFormat.xsd'}
#       host "localhost"
#       port 7676
#       username 'imqadmin'
#       passfile '/etc/omq/omqadmin.pass'
#     end

actions :create, :destroy

# <> @attribute destination_name The name of the destination.
attribute :destination_name, kind_of: String, name_attribute: true
# <> @attribute queue True if the destination is a queue, false for a topic.
attribute :queue, kind_of: [TrueClass, FalseClass], required: true
# <> @attribute config The configuration settings for queue. Valid properties include those exposed by JMX. Also supports the key 'schema' containing a URL which expands to 'validateXMLSchemaEnabled=true' and 'XMLSchemaURIList=$uri'.
attribute :config, kind_of: Hash, default: {}

# <> @attribute host The host of the OpenMQ message broker instance.
attribute :host, kind_of: String, required: true
# <> @attribute port The port of the portmapper service in message broker instance.
attribute :port, kind_of: Integer, required: true
# <> @attribute username The username used to connect to message broker.
attribute :username, kind_of: String, default: 'imqadmin'
# <> @attribute passfile The filename of a property file that contains a password for admin user set using the property "imq.imqcmd.password".
attribute :passfile, kind_of: String, required: true

# <> @attribute system_user The user that the domain executes as. Defaults to `node['glassfish']['user']` if unset.
attribute :system_user, kind_of: String, default: nil
# <> @attribute system_group The group that the domain executes as. Defaults to `node['glassfish']['group']` if unset.
attribute :system_group, kind_of: String, default: nil

default_action :create

def initialize(*args)
  super
  @system_user = node['glassfish']['user']
  @system_group = node['glassfish']['group']
end
