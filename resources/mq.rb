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

# Creates an OpenMQ message broker instance, creates an OS-level service and starts the service.
#
# @action create Create the message broker instance, enable and start the associated service.
# @action destroy Stop the associated service and delete the instance directory and associated artifacts.
#
# @section Examples
#
#     # Create a basic mq broker instance
#     glassfish_mq "MessageBroker" do
#       port 80
#       jmx_port 8089
#       jmx_admins { 'admin' => 'secret1' }
#       jmx_monitors { 'monitoring_system' => 'secret2' }
#       logging_properties {
#         "handlers" => "java.util.logging.ConsoleHandler, gelf4j.logging.GelfHandler",
#           ".level" => "INFO",
#           "java.util.logging.ConsoleHandler.level" => "INFO",
#           "gelf4j.logging.GelfHandler.level" => "ALL",
#           "gelf4j.logging.GelfHandler.host" => 'graylog.example.org',
#           "gelf4j.logging.GelfHandler.defaultFields" => '{"environment": "' + node.chef_environment + '", "facility": "MyInstance"}'
#       }
#       users { 'MyApp' => 'MyAppsPassword', 'MyOtherApp' => 'S3Cr37' }
#       queues { 'MySystem.MyMessageQueue' => {'XMLSchemaURIList' => 'http://example.com/...'} }
#       access_control_rules {
#         'queue.MySystem.MyMessageQueue.browse.allow.user' => '*',
#           'queue.MySystem.MyMessageQueue.produce.allow.user' => 'MyApp',
#           'queue.MySystem.MyMessageQueue.consume.allow.user' => 'MyOtherApp'
#       }
#     end

actions :create, :destroy

# <> @attribute max_memory The amount of heap memory to allocate to the domain in MiB.
attribute :max_memory, kind_of: Integer, default: 512
# <> @attribute max_stack_size The amount of stack memory to allocate to the domain in KiB.
attribute :max_stack_size, kind_of: Integer, default: 250
# <> @attribute instance The name of the broker instance.
attribute :instance, kind_of: String, name_attribute: true
# <> @attribute users A map of users to passwords for interacting with the service.
attribute :users, kind_of: Hash, default: {}
# <> @attribute access_control_rules An access control list of patterns to users.
attribute :access_control_rules, kind_of: Hash, default: {}
# <> @attribute logging_properties A hash of properties that will be merged into logging.properties. Use this to send logs to syslog or graylog.
attribute :logging_properties,
          kind_of: Hash,
          default:
            {
              'handlers' => 'java.util.logging.ConsoleHandler',
              '.level' => 'INFO',
              'java.util.logging.ConsoleHandler.level' => 'INFO',
            }
# <> @attribute config A map of key-value properties that are merged into the OpenMQ configuration file.
attribute :config, kind_of: Hash, default: {}
# <> @attribute queues A map of queue names to queue properties.
attribute :queues, kind_of: Hash, default: {}
# <> @attribute topics A map of topic names to topic properties.
attribute :topics, kind_of: Hash, default: {}
# <> @attribute jmx_admins A map of username to password for read-write JMX admin interface. Ignored unless jmx_port is specified.
attribute :jmx_admins, kind_of: Hash, default: {}
# <> @attribute jmx_monitors A map of username to password for read-only JMX admin interface. Ignored unless jmx_port is specified.
attribute :jmx_monitors, kind_of: Hash, default: {}
# <> @attribute admin_user The user in the users map that is used during administration.
attribute :admin_user, kind_of: String, default: 'imqadmin'

# <> @attribute port The port for the portmapper to bind.
attribute :port, kind_of: Integer, default: 7676
# <> @attribute admin_port The port on which admin service will bind.
attribute :admin_port, kind_of: Integer, default: 7677
# <> @attribute jms_port The port on which jms service will bind.
attribute :jms_port, kind_of: Integer, default: 7678
# <> @attribute jmx_port The port on which jmx service will bind. If not specified, no jmx service will be exported.
attribute :jmx_port, kind_of: Integer, default: nil
# <> @attribute rmi_port The port on which rmi service will bind. If not specified, a random port will be used. Typically used to lock down port for jmx access through firewalls.
attribute :rmi_port, kind_of: Integer, default: nil
# <> @attribute stomp_port The port on which the stomp service will bind. If not specified, no stomp service will execute.
attribute :stomp_port, kind_of: Integer, default: nil

# <> @attribute system_user The user that the domain executes as. Defaults to `node['glassfish']['user']` if unset.
attribute :system_user, kind_of: String, default: nil
# <> @attribute system_group The group that the domain executes as. Defaults to `node['glassfish']['group']` if unset.
attribute :system_group, kind_of: String, default: nil

# <> @attribute init_style The init system used to run the service.
attribute :init_style, equal_to: %w(upstart runit), default: 'upstart'

default_action :create

def initialize(*args)
  super
  @system_user = node['glassfish']['user']
  @system_group = node['glassfish']['group']
end
