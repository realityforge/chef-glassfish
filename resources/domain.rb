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

# Creates a GlassFish application domain, creates an OS-level service and starts the service.
#
# @action create  Create the domain, enable and start the associated service.
# @action destroy Stop the associated service and delete the domain directory and associated artifacts.
#
# @section Examples
#
#     # Create a basic domain that logs to a central graylog server
#     glassfish_domain "my_domain" do
#       port 80
#       admin_port 8103
#       extra_libraries ['http://central.maven.org/maven2/org/realityforge/gelf4j/gelf4j/1.10/gelf4j-1.10-all.jar']
#       logging_properties {
#         "handlers" => "java.util.logging.ConsoleHandler, gelf4j.logging.GelfHandler",
#         ".level" => "INFO",
#         "java.util.logging.ConsoleHandler.level" => "INFO",
#         "gelf4j.logging.GelfHandler.level" => "ALL",
#         "gelf4j.logging.GelfHandler.host" => 'graylog.example.org',
#         "gelf4j.logging.GelfHandler.defaultFields" => '{"environment": "' + node.chef_environment + '", "facility": "MyDomain"}'
#       }
#     end

actions :create, :destroy

# <> @attribute The minimum memory to allocate to the domain in MiB.
attribute :min_memory, kind_of: Integer, default: 512
# <> @attribute max_memory The amount of heap memory to allocate to the domain in MiB.
attribute :max_memory, kind_of: Integer, default: 512
# <> @attribute max_perm_size The amount of perm gen memory to allocate to the domain in MiB.
attribute :max_perm_size, kind_of: Integer, default: 96
# <> @attribute max_stack_size The amount of stack memory to allocate to the domain in KiB.
attribute :max_stack_size, kind_of: Integer, default: 350
# <> @attribute port The port on which the HTTP service will bind.
attribute :port, kind_of: Integer, default: 8080
# <> @attribute admin_port The port on which the web management console is bound.
attribute :admin_port, kind_of: Integer, default: 4848
# <> @attribute extra_jvm_options An array of extra arguments to pass the JVM.
attribute :extra_jvm_options, kind_of: Array, default: []
# <> @attribute java_agents An array of javaagent arguments to pass the JVM.
attribute :java_agents, kind_of: Array, default: []
# <> @attribute env_variables A hash of environment variables set when running the domain.
attribute :env_variables, kind_of: Hash, default: {}
# <> @attribute portbase Portbase from which port and admin_port are automatically calculated. Warning: This can't be used together with admin_port.
attribute :portbase, kind_of: Integer

# <> @attribute systemd_enabled is a boolean value to use systemd or not.
attribute :systemd_enabled, kind_of: [TrueClass, FalseClass], default: false
# <> @attribute systemd_start_timeout is an integer value which sets the service start timeout in seconds.
attribute :systemd_start_timeout, kind_of: Integer, default: 90
# <> @attribute systemd_stop_timeout is an integer value which sets the service stop timeout in seconds.
attribute :systemd_stop_timeout, kind_of: Integer, default: 90
# <> @attribute domain_name The name of the domain.
attribute :domain_name, kind_of: String, name_attribute: true
# <> @attribute terse Use terse output from the underlying asadmin.
attribute :terse, kind_of: [TrueClass, FalseClass], default: false
# <> @attribute echo If true, echo commands supplied to asadmin.
attribute :echo, kind_of: [TrueClass, FalseClass], default: true
# <> @attribute username The username to use when communicating with the domain.
attribute :username, kind_of: String, default: nil
# <> @attribute master_password Password used to access the keystore. Defaults to password if unset.
attribute :master_password, kind_of: String, default: nil
# <> @attribute password Password to use when communicating with the domain. Must be set if username is set.
attribute :password, kind_of: String, default: nil
# <> @attribute password_file The file in which the password is saved. Should be set if username is set.
attribute :password_file, kind_of: String, default: nil
# <> @attribute secure If true use SSL when communicating with the domain for administration.
attribute :secure, kind_of: [TrueClass, FalseClass], default: false
# <> @attribute logging_properties A hash of properties that will be merged into logging.properties. Use this to send logs to syslog or graylog.
attribute :logging_properties, kind_of: Hash, default: {}
# <> @attribute realm_types A map of names to realm implementation classes that is merged into the default realm types.
attribute :realm_types, kind_of: Hash, default: {}
# <> @attribute certificate_cn The common name that should be used when generating the self-signed ssl certificate for the domain
attribute :certificate_cn, kind_of: String, default: nil

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
    '-server',
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
    "-Dcom.sun.aas.instanceRoot=#{domain_dir_path}",
    '-Dcom.sun.enterprise.config.config_environment_factory_class=com.sun.enterprise.config.serverbeans.AppserverConfigEnvironmentFactory',
    '-DANTLR_USE_DIRECT_CLASS_LOADING=true',
    '-javaagent:${com.sun.aas.installRoot}/lib/monitor/flashlight-agent.jar',
    "-Djava.ext.dirs=#{node['java']['java_home']}/lib/ext${path.separator}#{node['java']['java_home']}/jre/lib/ext${path.separator}#{domain_dir_path}/lib/ext",
    '-Djava.endorsed.dirs=${com.sun.aas.installRoot}/modules/endorsed${path.separator}${com.sun.aas.installRoot}/lib/endorsed',
  ]
end

def osgi_jvm_options
  [
    '-Dosgi.shell.telnet.maxconn=1',
    '-Dfelix.fileinstall.disableConfigSave=false',
    '-Dfelix.fileinstall.dir=${com.sun.aas.installRoot}/modules/autostart/',
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

def grizzly_options
  if node['glassfish']['variant'] == 'payara' && node['glassfish']['version'].split('.')[0].to_i >= 5 && node['glassfish']['version'].split('.')[1].to_i >= 184
    [
      '[1.8.0|1.8.0u120]-Xbootclasspath/p:${com.sun.aas.installRoot}/lib/grizzly-npn-bootstrap-1.6.jar',
      '[1.8.0u121|1.8.0u160]-Xbootclasspath/p:${com.sun.aas.installRoot}/lib/grizzly-npn-bootstrap-1.7.jar',
      '[1.8.0u161|1.8.0u190]-Xbootclasspath/p:${com.sun.aas.installRoot}/lib/grizzly-npn-bootstrap-1.8.jar',
      '[1.8.0u191|1.8.0u250]-Xbootclasspath/p:${com.sun.aas.installRoot}/lib/grizzly-npn-bootstrap-1.8.1.jar',
      '[1.8.0u251|]-Xbootclasspath/a:${com.sun.aas.installRoot}/lib/grizzly-npn-api.jar',
    ]
  else
    []
  end
end

def development_jvm_options
  [
    '-Djdbc.drivers=org.apache.derby.jdbc.ClientDriver',
  ]
end

def default_jvm_options
  grizzly_options +
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

def default_logging_properties
  {
    'handlers' => 'java.util.logging.ConsoleHandler',
    'handlerServices' => 'com.sun.enterprise.server.logging.GFFileHandler,com.sun.enterprise.server.logging.SyslogHandler',

    'java.util.logging.ConsoleHandler.formatter' => 'com.sun.enterprise.server.logging.UniformLogFormatter',

    'com.sun.enterprise.server.logging.GFFileHandler.formatter' => 'com.sun.enterprise.server.logging.UniformLogFormatter',
    'com.sun.enterprise.server.logging.GFFileHandler.file' => '${com.sun.aas.instanceRoot}/logs/server.log',
    'com.sun.enterprise.server.logging.GFFileHandler.rotationTimelimitInMinutes' => '0',
    'com.sun.enterprise.server.logging.GFFileHandler.flushFrequency' => '1',
    'com.sun.enterprise.server.logging.GFFileHandler.logtoConsole' => 'false',
    'com.sun.enterprise.server.logging.GFFileHandler.rotationLimitInBytes' => '2000000',
    'com.sun.enterprise.server.logging.GFFileHandler.retainErrorsStasticsForHours' => '0',
    'com.sun.enterprise.server.logging.GFFileHandler.maxHistoryFiles' => '3',
    'com.sun.enterprise.server.logging.GFFileHandler.rotationOnDateChange' => 'false',

    'com.sun.enterprise.server.logging.SyslogHandler.useSystemLogging' => 'false',

    'log4j.logger.org.hibernate.validator.util.Version' => 'warn',

    # Payara 5.182
    'fish.payara.enterprise.server.logging.PayaraNotificationFileHandler.compressOnRotation' => 'false',
    'fish.payara.enterprise.server.logging.PayaraNotificationFileHandler.rotationLimitInBytes' => '2000000',
    'fish.payara.enterprise.server.logging.PayaraNotificationFileHandler.rotationOnDateChange' => 'false',
    'fish.payara.enterprise.server.logging.PayaraNotificationFileHandler.file' => '${com.sun.aas.instanceRoot}/logs/notification.log',
    'fish.payara.enterprise.server.logging.PayaraNotificationFileHandler.logtoFile' => 'true',
    'fish.payara.enterprise.server.logging.PayaraNotificationFileHandler.maxHistoryFiles' => '0',
    'com.sun.enterprise.server.logging.GFFileHandler.logtoFile' => 'true',
    'fish.payara.enterprise.server.logging.PayaraNotificationFileHandler.rotationTimelimitInMinutes' => '0',

    # Payara 5.183
    'fish.payara.enterprise.server.logging.PayaraNotificationFileHandler.formatter' => 'com.sun.enterprise.server.logging.ODLLogFormatter',

    # Payara 5.192
    'com.sun.enterprise.server.logging.GFFileHandler.logStandardStreams' => 'true',

    # Payara 5.2021.10
    'com.sun.enterprise.server.logging.GFFileHandler.fastLogging' => 'false',

    # All log level details
    '.level' => 'INFO',

    'com.sun.enterprise.server.logging.GFFileHandler.level' => 'ALL',
    'javax.enterprise.system.tools.admin.level' => 'INFO',
    'org.apache.jasper.level' => 'INFO',
    'javax.enterprise.resource.corba.level' => 'INFO',
    'javax.enterprise.system.core.level' => 'INFO',
    'javax.enterprise.system.core.classloading.level' => 'INFO',
    'java.util.logging.ConsoleHandler.level' => 'FINEST',
    'javax.enterprise.system.webservices.saaj.level' => 'INFO',
    'javax.enterprise.system.tools.deployment.level' => 'INFO',
    'javax.enterprise.system.container.ejb.level' => 'INFO',
    'javax.enterprise.system.core.transaction.level' => 'INFO',
    'org.apache.catalina.level' => 'INFO',
    'javax.enterprise.system.container.ejb.mdb.level' => 'INFO',
    'org.apache.coyote.level' => 'INFO',
    'javax.level' => 'INFO',
    'javax.enterprise.resource.javamail.level' => 'INFO',
    'javax.enterprise.system.webservices.rpc.level' => 'INFO',
    'javax.enterprise.system.container.web.level' => 'INFO',
    'javax.enterprise.system.util.level' => 'INFO',
    'javax.enterprise.resource.resourceadapter.level' => 'INFO',
    'javax.enterprise.resource.jms.level' => 'INFO',
    'javax.enterprise.system.core.config.level' => 'INFO',
    'javax.enterprise.system.level' => 'INFO',
    'javax.enterprise.system.core.security.level' => 'INFO',
    'javax.enterprise.system.container.cmp.level' => 'INFO',
    'javax.enterprise.system.webservices.registry.level' => 'INFO',
    'javax.enterprise.system.core.selfmanagement.level' => 'INFO',
    'javax.enterprise.resource.jdo.level' => 'INFO',
    'javax.enterprise.system.core.naming.level' => 'INFO',
    'javax.enterprise.resource.webcontainer.jsf.application.level' => 'INFO',
    'javax.enterprise.resource.webcontainer.jsf.resource.level' => 'INFO',
    'javax.enterprise.resource.webcontainer.jsf.config.level' => 'INFO',
    'javax.enterprise.resource.webcontainer.jsf.context.level' => 'INFO',
    'javax.enterprise.resource.webcontainer.jsf.facelets.level' => 'INFO',
    'javax.enterprise.resource.webcontainer.jsf.lifecycle.level' => 'INFO',
    'javax.enterprise.resource.webcontainer.jsf.managedbean.level' => 'INFO',
    'javax.enterprise.resource.webcontainer.jsf.renderkit.level' => 'INFO',
    'javax.enterprise.resource.webcontainer.jsf.taglib.level' => 'INFO',
    'javax.enterprise.resource.webcontainer.jsf.timing.level' => 'INFO',
    'javax.enterprise.resource.jta.level' => 'WARNING',
    'javax.enterprise.resource.sqltrace.level' => 'FINE',
    'javax.org.glassfish.persistence.level' => 'INFO',
    'org.jvnet.hk2.osgiadapter.level' => 'INFO',
    'javax.enterprise.system.tools.backup.level' => 'INFO',
    'org.glassfish.admingui.level' => 'INFO',
    'javax.enterprise.system.ssl.security.level' => 'INFO',
    'ShoalLogger.level' => 'CONFIG',
    'org.eclipse.persistence.session.level' => 'INFO',
    'javax.enterprise.resource.resourceadapter.com.sun.gjc.spi.level' => 'WARNING',
    'com.hazelcast.level' => 'WARNING',
  }
end

def default_realm_confs
  common_confs = {
    'fileRealm' => 'com.sun.enterprise.security.auth.login.FileLoginModule',
    'ldapRealm' => 'com.sun.enterprise.security.auth.login.LDAPLoginModule',
    'solarisRealm' => 'com.sun.enterprise.security.auth.login.SolarisLoginModule',
  }

  if node['glassfish']['version'][0].to_i >= 4
    {
      'jdbcRealm' => 'com.sun.enterprise.security.ee.auth.login.JDBCLoginModule',
      'jdbcDigestRealm' => 'com.sun.enterprise.security.ee.auth.login.JDBCDigestLoginModule',
      'pamRealm' => 'com.sun.enterprise.security.ee.auth.login.PamLoginModule',
    }.merge common_confs
  else
    {
      'jdbcRealm' => 'com.sun.enterprise.security.auth.login.JDBCLoginModule',
      'jdbcDigestRealm' => 'com.sun.enterprise.security.auth.login.JDBCDigestLoginModule',
      'pamRealm' => 'com.sun.enterprise.security.auth.login.PamLoginModule',
    }.merge common_confs
  end
end
