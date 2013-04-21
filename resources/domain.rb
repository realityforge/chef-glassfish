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

=begin
#<
Creates a GlassFish application domain, creates an OS-level service and starts the service.

@action create  Create the domain, enable and start the associated service.
@action destroy Stop the associated service and delete the domain directory and associated artifacts.

@section Examples

    # Create a basic domain that logs to a central graylog server
    glassfish_domain "my_domain" do
      port 80
      admin_port 8103
      extra_libraries ['https://github.com/downloads/realityforge/gelf4j/gelf4j-0.9-all.jar']
      logging_properties {
        "handlers" => "java.util.logging.ConsoleHandler, gelf4j.logging.GelfHandler",
        ".level" => "INFO",
        "java.util.logging.ConsoleHandler.level" => "INFO",
        "gelf4j.logging.GelfHandler.level" => "ALL",
        "gelf4j.logging.GelfHandler.host" => 'graylog.example.org',
        "gelf4j.logging.GelfHandler.defaultFields" => '{"environment": "' + node.chef_environment + '", "facility": "MyDomain"}'
      }
    end
#>
=end

actions :create, :destroy

#<> @attribute The minimum memory to allocate to the domain in MiB.
attribute :min_memory, :kind_of => Integer, :default => 512
#<> @attribute max_memory The amount of heap memory to allocate to the domain in MiB.
attribute :max_memory, :kind_of => Integer, :default => 512
#<> @attribute max_perm_size The amount of perm gen memory to allocate to the domain in MiB.
attribute :max_perm_size, :kind_of => Integer, :default => 96
#<> @attribute max_stack_size The amount of stack memory to allocate to the domain in KiB.
attribute :max_stack_size, :kind_of => Integer, :default => 128
#<> @attribute port The port on which the HTTP service will bind.
attribute :port, :kind_of => Integer, :default => 8080
#<> @attribute admin_port The port on which the web management console is bound.
attribute :admin_port, :kind_of => Integer, :default => 4848
#<> @attribute extra_jvm_options An array of extra arguments to pass the JVM.
attribute :extra_jvm_options, :kind_of => Array, :default => []
#<> @attribute env_variables A hash of environment variables set when running the domain.
attribute :env_variables, :kind_of => Hash, :default => {}

#<> @attribute domain_name The name of the domain.
attribute :domain_name, :kind_of => String, :name_attribute => true
#<> @attribute terse Use terse output from the underlying asadmin.
attribute :terse, :kind_of => [TrueClass, FalseClass], :default => false
#<> @attribute echo If true, echo commands supplied to asadmin.
attribute :echo, :kind_of => [TrueClass, FalseClass], :default => true
#<> @attribute username The username to use when communicating with the domain.
attribute :username, :kind_of => String, :default => nil
#<> @attribute password Password to use when communicating with the domain. Must be set if username is set.
attribute :password, :kind_of => String, :default => nil
#<> @attribute password_file The file in which the password is saved. Should be set if username is set.
attribute :password_file, :kind_of => String, :default => nil
#<> @attribute secure If true use SSL when communicating with the domain for administration.
attribute :secure, :kind_of => [TrueClass, FalseClass], :default => false
#<> @attribute logging_properties A hash of properties that will be merged into logging.properties. Use this to send logs to syslog or graylog.
attribute :logging_properties, :kind_of => Hash, :default => {}
#<> @attribute realm_types A map of names to realm implementation classes that is merged into the default realm types.
attribute :realm_types, :kind_of => Hash, :default => {}

default_action :create
