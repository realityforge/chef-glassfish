#
# Copyright:: Akos Vandra
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

actions [:create, :delete]
default_action :create

# <> @attribute username to create
attribute :user_name, name_attribute: true, kind_of: String

attribute :target, kind_of: String, default: 'server'
# <> @attribute realm auth realm to create the user in
attribute :realm, kind_of: String, required: false
# <> @attribute default password to create the username with
attribute :password, kind_of: String, required: true

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

def initialize(*args)
  super(*args)
  @system_user = node['glassfish']['user']
  @system_group = node['glassfish']['group']
end
