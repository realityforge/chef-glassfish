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

actions :create, :delete

#<> @attribute listener_name The name of the network listener.
attribute :listener_name, :kind_of => String, :name_attribute => true
#<> @attribute address The IP address or the hostname (resolvable by DNS).
attribute :address, :kind_of => String
#<> @attribute listenerport The port number to create the listen socket on. Legal values are 1-65535. On UNIX, creating sockets that listen on ports 1-1024 requires superuser privileges. Configuring an SSL listen socket to listen on port 443 is standard.
attribute :listenerport, :kind_of => Integer, :required => true
#<> @attribute threadpool The name of the thread pool for this listener. Specifying a thread pool is optional.
attribute :threadpool, :kind_of => String, :default => 'http-thread-pool'
#<> @attribute protocol The name of the protocol for this listener.
attribute :protocol, :kind_of => String, :required => true
#<> @attribute transport The name of the transport for this listener. Specifying a transport is optional.
attribute :transport, :kind_of => String, :default => 'tcp'
#<> @attribute enabled If set to `true`, the default, the listener is enabled at runtime.
attribute :enabled, :kind_of => [TrueClass, FalseClass], :default => true
#<> @attribute jkenabled If set to `true`, `mod_jk` is enabled for this listener.
attribute :jkenabled, :kind_of => [TrueClass, FalseClass], :default => false
#<> @attribute target Creates the network listener only on the specified target. Valid values are as follows: `server`, configuration-name, cluster-name, standalone-instance-name
attribute :target, :kind_of => String, :default => 'server'

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

default_action :create

def initialize(*args)
  super
  @system_user = node['glassfish']['user']
  @system_group = node['glassfish']['group']
end
