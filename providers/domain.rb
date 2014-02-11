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

include Chef::Asadmin

def default_logging_properties
  {
    "handlers" => "java.util.logging.ConsoleHandler",
    "java.util.logging.ConsoleHandler.formatter" => "com.sun.enterprise.server.logging.UniformLogFormatter",

    "com.sun.enterprise.server.logging.GFFileHandler.formatter" => "com.sun.enterprise.server.logging.UniformLogFormatter",
    "com.sun.enterprise.server.logging.GFFileHandler.file" => "${com.sun.aas.instanceRoot}/logs/server.log",
    "com.sun.enterprise.server.logging.GFFileHandler.rotationTimelimitInMinutes" => "0",
    "com.sun.enterprise.server.logging.GFFileHandler.flushFrequency" => "1",
    "com.sun.enterprise.server.logging.GFFileHandler.logtoConsole" => "false",
    "com.sun.enterprise.server.logging.GFFileHandler.rotationLimitInBytes" => "2000000",
    "com.sun.enterprise.server.logging.GFFileHandler.retainErrorsStasticsForHours" => "0",
    "com.sun.enterprise.server.logging.GFFileHandler.maxHistoryFiles" => "3",
    "com.sun.enterprise.server.logging.GFFileHandler.rotationOnDateChange" => "false",

    "com.sun.enterprise.server.logging.SyslogHandler.useSystemLogging" => "false",

    "log4j.logger.org.hibernate.validator.util.Version" => "warn",

    #All log level details
    ".level" => "INFO",

    "com.sun.enterprise.server.logging.GFFileHandler.level" => "ALL",
    "javax.enterprise.system.tools.admin.level" => "INFO",
    "org.apache.jasper.level" => "INFO",
    "javax.enterprise.resource.corba.level" => "INFO",
    "javax.enterprise.system.core.level" => "INFO",
    "javax.enterprise.system.core.classloading.level" => "INFO",
    "javax.enterprise.resource.jta.level" => "INFO",
    "java.util.logging.ConsoleHandler.level" => "FINEST",
    "javax.enterprise.system.webservices.saaj.level" => "INFO",
    "javax.enterprise.system.tools.deployment.level" => "INFO",
    "javax.enterprise.system.container.ejb.level" => "INFO",
    "javax.enterprise.system.core.transaction.level" => "INFO",
    "org.apache.catalina.level" => "INFO",
    "javax.enterprise.system.container.ejb.mdb.level" => "INFO",
    "org.apache.coyote.level" => "INFO",
    "javax.level" => "INFO",
    "javax.enterprise.resource.javamail.level" => "INFO",
    "javax.enterprise.system.webservices.rpc.level" => "INFO",
    "javax.enterprise.system.container.web.level" => "INFO",
    "javax.enterprise.system.util.level" => "INFO",
    "javax.enterprise.resource.resourceadapter.level" => "INFO",
    "javax.enterprise.resource.jms.level" => "INFO",
    "javax.enterprise.system.core.config.level" => "INFO",
    "javax.enterprise.system.level" => "INFO",
    "javax.enterprise.system.core.security.level" => "INFO",
    "javax.enterprise.system.container.cmp.level" => "INFO",
    "javax.enterprise.system.webservices.registry.level" => "INFO",
    "javax.enterprise.system.core.selfmanagement.level" => "INFO",
    "javax.enterprise.resource.jdo.level" => "INFO",
    "javax.enterprise.system.core.naming.level" => "INFO",
    "javax.enterprise.resource.webcontainer.jsf.application.level" => "INFO",
    "javax.enterprise.resource.webcontainer.jsf.resource.level" => "INFO",
    "javax.enterprise.resource.webcontainer.jsf.config.level" => "INFO",
    "javax.enterprise.resource.webcontainer.jsf.context.level" => "INFO",
    "javax.enterprise.resource.webcontainer.jsf.facelets.level" => "INFO",
    "javax.enterprise.resource.webcontainer.jsf.lifecycle.level" => "INFO",
    "javax.enterprise.resource.webcontainer.jsf.managedbean.level" => "INFO",
    "javax.enterprise.resource.webcontainer.jsf.renderkit.level" => "INFO",
    "javax.enterprise.resource.webcontainer.jsf.taglib.level" => "INFO",
    "javax.enterprise.resource.webcontainer.jsf.timing.level" => "INFO",
    "javax.enterprise.resource.sqltrace.level" => "FINE",
    "javax.org.glassfish.persistence.level" => "INFO",
    "org.jvnet.hk2.osgiadapter.level" => "INFO",
    "javax.enterprise.system.tools.backup.level" => "INFO",
    "org.glassfish.admingui.level" => "INFO",
    "javax.enterprise.system.ssl.security.level" => "INFO",
    "ShoalLogger.level" => "CONFIG",
    "org.eclipse.persistence.session.level" => "INFO",
  }
end

def default_realm_confs
  {
    "fileRealm" => "com.sun.enterprise.security.auth.login.FileLoginModule",
    "ldapRealm" => "com.sun.enterprise.security.auth.login.LDAPLoginModule",
    "solarisRealm" => "com.sun.enterprise.security.auth.login.SolarisLoginModule",
    "jdbcRealm" => "com.sun.enterprise.security.auth.login.JDBCLoginModule",
    "jdbcDigestRealm" => "com.sun.enterprise.security.auth.login.JDBCDigestLoginModule",
    "pamRealm" => "com.sun.enterprise.security.auth.login.PamLoginModule",
  }
end

def default_jvm_options
  [
    # Don't rely on the JVMs default encoding
    "-Dfile.encoding=UTF-8",

    # Glassfish should be headless by default
    "-Djava.awt.headless=true",

    # Remove the "Server" header altogether
    "-Dproduct.name=",

    # JVM options
    "-XX:+UnlockDiagnosticVMOptions",
    "-XX:MaxPermSize=#{new_resource.max_perm_size}m",
    #"-XX:PermSize=64m",
    "-Xss#{new_resource.max_stack_size}k",
    "-Xms#{new_resource.min_memory}m",
    "-Xmx#{new_resource.max_memory}m",
    "-XX:NewRatio=2",
    "-client",
    "-Djava.ext.dirs=#{node['java']['java_home']}/lib/ext:#{node['java']['java_home']}/jre/lib/ext:#{domain_dir_path}/lib/ext",
    "-Djava.endorsed.dirs=#{node['glassfish']['base_dir']}/glassfish/modules/endorsed:#{node['glassfish']['domains_dir']}/glassfish/lib/endorsed",

      # Configuration to enable effective JMX management
    "-Djava.rmi.server.hostname=#{node['fqdn']}",
    "-Djava.net.preferIPv4Stack=true",

    "-Dcom.sun.aas.instanceRoot=#{domain_dir_path}",
    "-Dcom.sun.enterprise.config.config_environment_factory_class=com.sun.enterprise.config.serverbeans.AppserverConfigEnvironmentFactory",
    "-Dcom.sun.aas.installRoot=#{node['glassfish']['base_dir']}/glassfish",
    "-Dcom.sun.enterprise.security.httpsOutboundKeyAlias=s1as",
    "-DANTLR_USE_DIRECT_CLASS_LOADING=true",
    "-Djava.awt.headless=true",
    "-Djdbc.drivers=org.apache.derby.jdbc.ClientDriver",
    "-javaagent:#{node['glassfish']['base_dir']}/glassfish/lib/monitor/flashlight-agent.jar",

    #osgi_jvm_options
    "-Dosgi.shell.telnet.maxconn=1",
    "-Dfelix.fileinstall.disableConfigSave=false",
    "-Dfelix.fileinstall.dir=#{node['glassfish']['base_dir']}/glassfish/modules/autostart/",
    "-Dosgi.shell.telnet.port=6666",
    "-Dfelix.fileinstall.log.level=2",
    "-Dfelix.fileinstall.poll=5000",
    "-Dosgi.shell.telnet.ip=127.0.0.1",
    "-Dfelix.fileinstall.bundles.startTransient=true",
    "-Dfelix.fileinstall.bundles.new.start=true",
    "-Dgosh.args=--nointeractive",

    #security_jvm_options
    "-Djavax.net.ssl.keyStore=#{domain_dir_path}/config/keystore.jks",
    "-Djava.security.policy=#{domain_dir_path}/config/server.policy",
    "-Djavax.net.ssl.trustStore=#{domain_dir_path}/config/cacerts.jks",
    "-Dcom.sun.enterprise.security.httpsOutboundKeyAlias=s1as",
    "-Djava.security.auth.login.config=#{domain_dir_path}/config/login.conf",
  ]
end

def domain_dir_path
  "#{node['glassfish']['domains_dir']}/#{new_resource.domain_name}"
end

def domain_dir_arg
  "--domaindir #{node['glassfish']['domains_dir']}"
end

def replace_in_domain_file(key, value)
  "sed -i 's/#{key}/#{value}/g' #{domain_dir_path}/config/domain.xml 2> /dev/null > /dev/null"
end

use_inline_resources

action :create do
  service_name = "glassfish-#{new_resource.domain_name}"
  service_resource_name = new_resource.init_style == 'upstart' ? "service[#{service_name}]" : "runit_service[#{service_name}]"

  if new_resource.system_group != node['glassfish']['group']
    group new_resource.system_group do
    end
  end

  if new_resource.system_user != node['glassfish']['user']
    user new_resource.system_user do
      comment "GlassFish #{new_resource.domain_name} Domain"
      gid new_resource.system_group
      home "#{node['glassfish']['domains_dir']}/#{new_resource.domain_name}"
      shell '/bin/bash'
      system true
    end
  end

  requires_authbind = new_resource.port < 1024 || new_resource.admin_port < 1024

  service service_name do
    provider Chef::Provider::Service::Upstart
    supports :start => true, :restart => true, :stop => true, :status => true
    action :nothing
  end

  args = default_jvm_options.dup
  args += new_resource.extra_jvm_options
  args << "-cp"
  args << "#{node['glassfish']['base_dir']}/glassfish/modules/glassfish.jar"
  args << "com.sun.enterprise.glassfish.bootstrap.ASMain"
  args << "-domainname"
  args << new_resource.domain_name
  args << "-instancename"
  args << "server"
  args << "-verbose"
  args << "false"
  args << "-debug"
  args << "false"
  args << "-upgrade"
  args << "false"
  args << "-type"
  args << "DAS"
  args << "-domaindir"
  args << domain_dir_path

  directory node['glassfish']['domains_dir'] do
    owner node['glassfish']['user']
    group node['glassfish']['group']
    mode "0755"
    recursive true
  end

  if new_resource.password_file
    template new_resource.password_file do
      cookbook 'glassfish'
      only_if { new_resource.password }
      source "password.erb"
      owner new_resource.system_user
      group new_resource.system_group
      mode "0600"
      variables :password => new_resource.password
    end
  end

  authbind_port "AuthBind GlassFish Port #{new_resource.port}" do
    only_if { new_resource.port < 1024 }
    port new_resource.port
    user new_resource.system_user
  end

  authbind_port "AuthBind GlassFish Port #{new_resource.admin_port}" do
    only_if { new_resource.admin_port < 1024 }
    port new_resource.admin_port
    user new_resource.system_user
  end

  bash "create domain #{new_resource.domain_name}" do
    not_if "#{asadmin_command('list-domains')} #{domain_dir_arg}| grep -- '#{new_resource.domain_name} '"

    create_args = []
    create_args << "--checkports=false"
    create_args << "--savemasterpassword=true" if node['glassfish']['version'][0] == '4'
    create_args << "--instanceport #{new_resource.port}"
    create_args << "--adminport #{new_resource.admin_port}"
    create_args << "--nopassword=false" if new_resource.username
    create_args << domain_dir_arg
    command_string = []
    command_string << (requires_authbind ? "authbind --deep " : "") + asadmin_command("create-domain #{create_args.join(' ')} #{new_resource.domain_name}", false)
    command_string << replace_in_domain_file("%%%CPU_NODE_COUNT%%%", node['cpu'].size - 2)
    command_string << replace_in_domain_file("%%%MAX_PERM_SIZE%%%", new_resource.max_perm_size)
    command_string << replace_in_domain_file("%%%MAX_STACK_SIZE%%%", new_resource.max_stack_size)
    command_string << replace_in_domain_file("%%%MAX_MEM_SIZE%%%", new_resource.max_memory)
    command_string << replace_in_domain_file("%%%MIN_MEM_SIZE%%%", new_resource.min_memory)
    command_string << asadmin_command("verify-domain-xml #{domain_dir_arg} #{new_resource.domain_name}", false)

    user new_resource.system_user
    group new_resource.system_group
    code command_string.join("\n")
  end

  file "#{domain_dir_path}/docroot/index.html" do
    action :delete
  end

  # There is a bug in the Glassfish 4 domain creation that puts the master-password in the wrong spot. This copies it back.
  #file "#{domain_dir_path}/master-password" do
  # ruby_block "copy master-password" do
  #   source_file = "#{domain_dir_path}/config/master-password"
  #   dest_file = "#{domain_dir_path}/master-password"

  #   only_if { node['glassfish']['version'][0] == '4' }
  #   only_if { ::File.exists?(source_file) }
  #   not_if { ::File.exists?(dest_file) }

  #   block do
  #     FileUtils.cp(source_file, dest_file)
  #     FileUtils.chown( new_resource.system_user, new_resource.system_group, dest_file)
  #   end
  # end

  template "#{domain_dir_path}/config/logging.properties" do
    source "logging.properties.erb"
    mode "0400"
    cookbook 'glassfish'
    owner new_resource.system_user
    group new_resource.system_group
    variables(:logging_properties => default_logging_properties.merge(new_resource.logging_properties))
    notifies :restart, service_resource_name, :delayed
  end

  template "#{domain_dir_path}/config/login.conf" do
    source "login.conf.erb"
    mode "0400"
    cookbook 'glassfish'
    owner new_resource.system_user
    group new_resource.system_group
    variables(:realm_types => default_realm_confs.merge(new_resource.realm_types))
    notifies :restart, service_resource_name, :delayed
  end

  if new_resource.init_style == 'upstart'
    template "/etc/init/glassfish-#{new_resource.domain_name}.conf" do
      source "glassfish-upstart.conf.erb"
      mode "0644"
      cookbook 'glassfish'

      variables(:resource => new_resource, :args => args, :authbind => requires_authbind, :listen_ports => [new_resource.admin_port, new_resource.port])
      notifies :restart, service_resource_name, :delayed
    end

    service service_name do
      provider Chef::Provider::Service::Upstart
      supports :start => true, :restart => true, :stop => true, :status => true
      action [:enable, :start]
    end
  elsif new_resource.init_style == 'runit'
    runit_service service_name do
      default_logger true
      check true
      cookbook 'glassfish'
      run_template_name 'glassfish'
      check_script_template_name 'glassfish'
      options(:resource => new_resource, :args => args, :authbind => requires_authbind, :listen_ports => [new_resource.admin_port, new_resource.port])
      sv_timeout 100
      action [:enable, :start]
    end

    bash "runit check" do
      code "#{node["runit"]["sv_bin"]} -w '120' check #{node["runit"]["sv_dir"]}/#{service_name}"
    end
  else
    raise "Unknown init style #{new_resource.init_style}"
  end
end

action :destroy do
  service_name = "glassfish-#{new_resource.domain_name}"
  if new_resource.init_style == 'upstart'
    service service_name do
      provider Chef::Provider::Service::Upstart
      action [:stop, :disable]
      ignore_failure true
    end

    file "/etc/init/glassfish-#{new_resource.domain_name}.conf" do
      action :delete
    end
  elsif new_resource.init_style == 'runit'
    runit_service service_name do
      ignore_failure true
      action [:stop, :disable]
    end
  else
    raise "Unknown init style #{new_resource.init_style}"
  end

  directory domain_dir_path do
    recursive true
    action :delete
  end
end
