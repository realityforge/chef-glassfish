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
require 'digest/sha1'

actions :deploy, :undeploy, :enable, :disable

attribute :component_name, :kind_of => String, :name_attribute => true
attribute :version, :kind_of => String, :default => nil
attribute :target, :kind_of => String, :default => 'server'
attribute :url, :kind_of => String, :default => nil
#<> @attribute auth_username Username to use if artifact is protected
attribute :auth_username, :kind_of => String, :default => nil
#<> @attribute auth_password Password to use if artifact is protected
attribute :auth_password, :kind_of => String, :default => nil

attribute :enabled, :equal_to => [true, false, 'true', 'false'], :default => true
attribute :type, :equal_to => [:osgi, 'osgi', nil], :default => nil
attribute :context_root, :kind_of => String, :default => nil
attribute :virtual_servers, :kind_of => Array, :default => []
attribute :generate_rmi_stubs, :equal_to => [true, false, 'true', 'false'], :default => false
attribute :availability_enabled, :equal_to => [true, false, 'true', 'false'], :default => false
attribute :lb_enabled, :equal_to => [true, false, 'true', 'false'], :default => true
attribute :skipdsfailure, :equal_to => [true, false, 'true', 'false'], :default => true
attribute :keep_state, :equal_to => [true, false, 'true', 'false'], :default => false
attribute :verify, :equal_to => [true, false, 'true', 'false'], :default => false
attribute :precompile_jsp, :equal_to => [true, false, 'true', 'false'], :default => false
attribute :async_replication, :equal_to => [true, false, 'true', 'false'], :default => true
attribute :properties, :kind_of => Hash, :default => {}
attribute :descriptors, :kind_of => Hash, :default => {}

#<> @attribute libraries Array of JAR file names deployed as applibs which are used by this deployable.
attribute :libraries, :kind_of => Array, :default => []

#<> @attribute domain_name The name of the domain.
attribute :domain_name, :kind_of => String, :required => true
#<> @attribute terse Use terse output from the underlying asadmin.
attribute :terse, :kind_of => [TrueClass, FalseClass], :default => false
#<> @attribute echo If true, echo commands supplied to asadmin.
attribute :echo, :kind_of => [TrueClass, FalseClass], :default => true
#<> @attribute username The username to use when communicating with the domain.
attribute :username, :kind_of => String, :default => nil
#<> @attribute password_file The file in which the password must be stored assigned to appropriate key.
attribute :password_file, :kind_of => String, :default => nil
#<> @attribute secure If true use SSL when communicating with the domain for administration.
attribute :secure, :kind_of => [TrueClass, FalseClass], :default => false
#<> @attribute admin_port The port on which the web management console is bound.
attribute :admin_port, :kind_of => Integer, :default => 4848

#<> @attribute system_user The user that the domain executes as. Defaults to `node['glassfish']['user']` if unset.
attribute :system_user, :kind_of => String, :default => nil
#<> @attribute system_group The group that the domain executes as. Defaults to `node['glassfish']['group']` if unset.
attribute :system_group, :kind_of => String, :default => nil

default_action :deploy

def initialize(*args)
  super
  @system_user = node['glassfish']['user']
  @system_group = node['glassfish']['group']
end

def version_value
  version.nil? ? Digest::SHA1.hexdigest(url) : version
end
