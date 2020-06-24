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

# Set a value that can be retrieved as a `web env entry` in a particular web application. This resource is idempotent and
# will not set the entry if it already exists and has the same value. Nil values can be specified. The java type of the
# value must also be specified.
#
# @action set Set the value as entry.
# @action unset Remove the entry.
#
# @section Examples
#
#     glassfish_web_env_entry "Set IntegrationServerURL" do
#        domain_name 'my_domain'
#        name 'IntegrationServerURL'
#        value 'http://example.com/Foo'
#        type 'java.lang.String'
#     end

actions :set, :unset

# <> @attribute webapp The name of the web application name.
attribute :webapp, kind_of: String, required: true
# <> @attribute name The key name of the web env entry.
attribute :glassfish_web_env_entry_name, kind_of: String, required: true
# <> @attribute type The java type name of env entry.
attribute :type, kind_of: String, default: 'java.lang.String'
# <> @attribute value The value of the entry.
attribute :value, kind_of: String, default: nil
# <> @attribute description A description of the entry.
attribute :description, kind_of: String, default: nil

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

default_action :set

def initialize(*args)
  super
  @system_user = node['glassfish']['user']
  @system_group = node['glassfish']['group']
end
