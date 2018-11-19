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
      extra_libraries ['http://central.maven.org/maven2/org/realityforge/gelf4j/gelf4j/1.10/gelf4j-1.10-all.jar']
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
attribute :max_stack_size, :kind_of => Integer, :default => 350
#<> @attribute port The port on which the HTTP service will bind.
attribute :port, :kind_of => Integer, :default => 8080
#<> @attribute admin_port The port on which the web management console is bound.
attribute :admin_port, :kind_of => Integer, :default => 4848
#<> @attribute extra_jvm_options An array of extra arguments to pass the JVM.
attribute :extra_jvm_options, :kind_of => Array, :default => []
#<> @attribute java_agents An array of javaagent arguments to pass the JVM.
attribute :java_agents, :kind_of => Array, :default => []
#<> @attribute env_variables A hash of environment variables set when running the domain.
attribute :env_variables, :kind_of => Hash, :default => {}
#<> @attribute env_var_file Path to the environment variables file to be exported
attribute :env_var_file, :kind_of => String, :default => nil
#<> @attribute portbase Portbase from which port and admin_port are automatically calculated. Warning: This can't be used together with admin_port.
attribute :portbase, :kind_of => Integer

#<> @attribute systemd_enabled is a boolean value to use systemd or not.
attribute :systemd_enabled, :kind_of => [TrueClass, FalseClass], :default => false
#<> @attribute systemd_start_timeout is an integer value which sets the service start timeout in seconds.
attribute :systemd_start_timeout, :kind_of => Integer, :default => 90
#<> @attribute systemd_stop_timeout is an integer value which sets the service stop timeout in seconds.
attribute :systemd_stop_timeout, :kind_of => Integer, :default => 90
#<> @attribute domain_name The name of the domain.
attribute :domain_name, :kind_of => String, :name_attribute => true
#<> @attribute terse Use terse output from the underlying asadmin.
attribute :terse, :kind_of => [TrueClass, FalseClass], :default => false
#<> @attribute echo If true, echo commands supplied to asadmin.
attribute :echo, :kind_of => [TrueClass, FalseClass], :default => true
#<> @attribute username The username to use when communicating with the domain.
attribute :username, :kind_of => String, :default => nil
#<> @attribute master_password Password used to access the keystore. Defaults to password if unset.
attribute :master_password, :kind_of => String, :default => nil
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

def domain_dir_path
  "#{node['glassfish']['domains_dir']}/#{domain_name}"
end

def runtime_jvm_options
  [
    # JVM options
    '-XX:+UnlockDiagnosticVMOptions',
    "-XX:MaxPermSize=#{max_perm_size}m",
    "-Xss#{max_stack_size}k",
    "-Xms#{min_memory}m",
    "-Xmx#{max_memory}m",
    '-XX:NewRatio=2',
    '-server'
  ]
end

def common_jvm_options
  [
    # Configuration to enable effective JMX management
    "-Djava.rmi.server.hostname=#{node['fqdn']}",
    '-Djava.net.preferIPv4Stack=true',

    # Don't rely on the JVMs default encoding
    '-Dfile.encoding=UTF-8',

    # Remove the 'Server' header altogether
    '-Dproduct.name=',

    # Glassfish should be headless by default
    '-Djava.awt.headless=true',
  ]
end

def installation_jvm_options
  [
    # TODO: All jvm options that have expanded node['glassfish']['install_dir'] should be replaced by ${com.sun.aas.installRoot} in modern glassfish versions and should also use${path.separator}
    "-Dcom.sun.aas.instanceRoot=#{domain_dir_path}",
    '-Dcom.sun.enterprise.config.config_environment_factory_class=com.sun.enterprise.config.serverbeans.AppserverConfigEnvironmentFactory',
    # TODO: Next line is not needed as of modern glassfish
    "-Dcom.sun.aas.installRoot=#{node['glassfish']['install_dir']}/glassfish",
    '-DANTLR_USE_DIRECT_CLASS_LOADING=true',
    "-javaagent:#{node['glassfish']['install_dir']}/glassfish/lib/monitor/flashlight-agent.jar",
    "-Djava.ext.dirs=#{node['java']['java_home']}/lib/ext:#{node['java']['java_home']}/jre/lib/ext:#{domain_dir_path}/lib/ext",
    "-Djava.endorsed.dirs=#{node['glassfish']['install_dir']}/glassfish/modules/endorsed:#{node['glassfish']['install_dir']}/glassfish/lib/endorsed",
  ]
end

def osgi_jvm_options
  [
    #osgi_jvm_options
    '-Dosgi.shell.telnet.maxconn=1',
    '-Dfelix.fileinstall.disableConfigSave=false',
    "-Dfelix.fileinstall.dir=#{node['glassfish']['install_dir']}/glassfish/modules/autostart/",
    '-Dosgi.shell.telnet.port=6666',
    '-Dfelix.fileinstall.log.level=2',
    '-Dfelix.fileinstall.poll=5000',
    '-Dosgi.shell.telnet.ip=127.0.0.1',
    '-Dfelix.fileinstall.bundles.startTransient=true',
    '-Dfelix.fileinstall.bundles.new.start=true',
    '-Dgosh.args=--nointeractive',
  ]
end

def security_jvm_options
  [
    '-Dcom.sun.enterprise.security.httpsOutboundKeyAlias=s1as',
    "-Djavax.net.ssl.keyStore=#{domain_dir_path}/config/keystore.jks",
    "-Djava.security.policy=#{domain_dir_path}/config/server.policy",
    "-Djavax.net.ssl.trustStore=#{domain_dir_path}/config/cacerts.jks",
    '-Dcom.sun.enterprise.security.httpsOutboundKeyAlias=s1as',
    "-Djava.security.auth.login.config=#{domain_dir_path}/config/login.conf",
  ]
end

def development_jvm_options
  [
    '-Djdbc.drivers=org.apache.derby.jdbc.ClientDriver',
  ]
end

def default_jvm_options
  runtime_jvm_options +
    development_jvm_options +
    common_jvm_options +
    installation_jvm_options +
    osgi_jvm_options +
    security_jvm_options
end

def jvm_options
  default_jvm_options +
    java_agents.map { |agent| "-javaagent:#{agent}" } +
    extra_jvm_options
end
