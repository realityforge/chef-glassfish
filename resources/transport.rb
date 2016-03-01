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

#<> @attribute transport_name The name of the transport.
attribute :transport_name, :kind_of => , :name_attribute => true
#<> @attribute acceptorthreads The number of acceptor threads for the transport. The recommended value is the number of processors in the machine.
attribute :acceptorthreads, :kind_of => Integer, :default => 1
#<> @attribute buffersizebytes The size, in bytes, of the buffer to be provided for input streams created by the network listener that references this transport.
attribute :buffersizebytes, :kind_of => Integer, :default => 8_192
#<> @attribute bytebuffertype The type of the buffer to be provided for input streams created by a network-listener. Allowed values are `HEAP` and `DIRECT`.
attribute :bytebuffertype, :equal_to => ['HEAP', 'DIRECT'], :default => 'HEAP'
#<> @attribute classname The fully qualified name of the Java class that implements the transport.
attribute :classname, :kind_of => String, :default => 'com.sun.grizzly.TCPSelectorHandler'
#<> @attribute displayconfiguration If `true`, flushes the internal network configuration to the server log. Useful for debugging, but reduces performance.
attribute :displayconfiguration, :kind_of => [TrueClass, FalseClass], :default => false
#<> @attribute enablesnoop If `true`, writes request/response information to the server log. Useful for debugging, but reduces performance.
attribute :enablesnoop, :kind_of => [TrueClass, FalseClass], :default => false
#<> @attribute idlekeytimeoutseconds The idle key timeout.
attribute :idlekeytimeoutseconds, :kind_of => Integer, :default => 30
#<> @attribute maxconnectionscount The maximum number of connections for the network listener that references this transport. A value of `-1` specifies no limit.
attribute :maxconnectionscount, :kind_of => Integer, :default => 4_096
#<> @attribute readtimeoutmillis The amount of time in milliseconds the server waits during the header and body parsing phase.
attribute :readtimeoutmillis, :kind_of => Integer, :default => 30_000
#<> @attribute writetimeoutmillis The amount of time in milliseconds the server waits before considering the remote client disconnected when writing the response.
attribute :writetimeoutmillis, :kind_of => Integer, :default => 30_000
#<> @attribute selectionkeyhandler The name of the selection key handler associated with this transport.
attribute :selectionkeyhandler, :kind_of => String
#<> @attribute selectorpolltimeoutmillis The number of milliseconds a NIO Selector blocks waiting for events (user requests).
attribute :selectorpolltimeoutmillis, :kind_of => Integer, :default => 1_000
#<> @attribute tcpnodelay If `true`, enables `TCP_NODELAY` (also called Nagle's algorithm).
attribute :, :kind_of => [TrueClass, FalseClass], :default => false
#<> @attribute target Creates the transport only on the specified target. Valid values are as follows: `server`, configuration-name, cluster-name, standalone-instance-name
attribute :, :kind_of => String, :default => 'server'

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
