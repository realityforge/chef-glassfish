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

# Creates a GlassFish server instance in the domain configuration.
#
# @action create  Create the instance and start it..
# @action delete  Stop the instance if running and remove it from the config.
#
# @section Examples
#
#     # Create a standalone Glassfish instance
#     glassfish_instance "Myserver" do
#       node_name 'localhost-domain1'
#       lbenabled false
#     end

actions :create, :delete

# <> @attribute The server instance's name.
attribute :instance_name, kind_of: String, name_attribute: true
# <> @attribute Glassfish node on which the instance should run.
attribute :node_name, kind_of: String, required: true # default: "localhost-#{domain_name}"
# <> @attribute Glassfish named configuration which the instance should use. If undefined, the server is going to be a standalone instance.
attribute :config_name, kind_of: String
# <> @attribute Switches the LB frontend bit on/off.
attribute :lbenabled, kind_of: [TrueClass, FalseClass]
# <> @attribute Defines the portbase in `asadmin` style.
attribute :portbase, kind_of: Integer
# <> @attribute Specifies whether to check for the availability of the administration, HTTP, JMS, JMX, and IIOP ports.
attribute :checkports, kind_of: [TrueClass, FalseClass]
# <> @attribute Defines system properties for the instance. These properties override property definitions for port settings in the instance's configuration.
attribute :systemproperties, kind_of: Hash, default: {}

# <> @attribute domain_name The name of the domain.
attribute :domain_name, kind_of: String, required: true
# <> @attribute terse Use terse output from the underlying asadmin.
attribute :terse, kind_of: [TrueClass, FalseClass], default: false
# <> @attribute echo If true, echo commands supplied to asadmin.
attribute :echo, kind_of: [TrueClass, FalseClass], default: true
# <> @attribute username The username to use when communicating with the domain.
attribute :username, kind_of: String, default: nil
# <> @attribute password_file The file in which the password must be stored assigned to appropriate key.
attribute :password_file, kind_of: String, default: nil
# <> @attribute secure If true use SSL when communicating with the domain for administration.
attribute :secure, kind_of: [TrueClass, FalseClass], default: false
# <> @attribute admin_port The port on which the web management console is bound.
attribute :admin_port, kind_of: Integer, default: 4848

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
