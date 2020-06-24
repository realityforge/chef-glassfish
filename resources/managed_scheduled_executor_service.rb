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

actions :create, :delete

attribute :jndi_name, kind_of: String, name_attribute: true

attribute :target, kind_of: String, default: 'server'
# <> @attribute enabled Determines whether the resource is enabled at runtime.
attribute :enabled, equal_to: [true, false, 'true', 'false'], default: true
# <> @attribute enabled Determines whether container contexts are propagated to threads. If set to true, the contexts specified in the --contextinfo option are propagated. If set to false, no contexts are propagated and the --contextinfo option is ignored.
attribute :contextinfoenabled, equal_to: [true, false, 'true', 'false'], default: true
# <> @attribute contextinfo Specifies individual container contexts to propagate to threads. Valid values are Classloader, JNDI, Security, and WorkArea. Values are specified in a comma-separated list and are case-insensitive. All contexts are propagated by default.
attribute :contextinfo, kind_of: String, default: 'Classloader,JNDI,Security,WorkArea'
# <> @attribute contextinfo Descriptive details about the resource.
attribute :description, kind_of: String
# <> @attribute threadpriority Specifies the priority to assign to created threads.
attribute :threadpriority, kind_of: Integer, default: 5
# <> @attribute longrunningtasks Specifies whether the resource should be used for long-running tasks. If set to true, long-running tasks are not reported as stuck.
attribute :longrunningtasks, equal_to: [true, false, 'true', 'false'], default: false
# <> @attribute hungafterseconds Specifies the number of seconds that a task can execute before it is considered unresponsive. If the value is 0 tasks are never considered unresponsive.
attribute :hungafterseconds, kind_of: Integer, default: 0
# <> @attribute corepoolsize Specifies the number of threads to keep in a thread pool, even if they are idle.
attribute :corepoolsize, kind_of: Integer, default: 0
# <> @attribute keepaliveseconds Specifies the number of seconds that threads can remain idle when the number of threads is greater than corepoolsize.
attribute :keepaliveseconds, kind_of: Integer, default: 60
# <> @attribute threadlifetimeseconds Specifies the number of seconds that threads can remain in a thread pool before being purged, regardless of whether the number of threads is greater than corepoolsize or whether the threads are idle. The value of 0 means that threads are never purged.
attribute :threadlifetimeseconds, kind_of: Integer, default: 0

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
