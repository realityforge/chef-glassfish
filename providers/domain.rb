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

def domain_dir_arg
  "--domaindir #{node['glassfish']['domains_dir']}"
end

def replace_in_domain_file(key, value)
  "sed -i 's/#{key}/#{value}/g' #{node['glassfish']['domains_dir']}/#{new_resource.domain_name}/config/domain.xml 2> /dev/null > /dev/null"
end

notifying_action :create do
  requires_authbind = new_resource.port < 1024 || new_resource.admin_port < 1024

  directory node['glassfish']['domains_dir'] do
    owner node['glassfish']['user']
    group node['glassfish']['group']
    mode "0700"
    recursive true
  end

  if new_resource.password_file
    template new_resource.password_file do
      only_if { new_resource.password }
      source "password.erb"
      owner node['glassfish']['user']
      group node['glassfish']['group']
      mode "0600"
      variables :password => new_resource.password
    end
  end

  template "/etc/init.d/glassfish-#{new_resource.domain_name}" do
    source "glassfish-init.d-script.erb"
    mode "0755"
    cookbook 'glassfish'
    variables(:domain_name => new_resource.domain_name, :authbind => requires_authbind, :listen_ports => [new_resource.admin_port, new_resource.port])
  end

  authbind_port "AuthBind GlassFish Port #{new_resource.port}" do
    only_if { new_resource.port < 1024 }
    port new_resource.port
    user node['glassfish']['user']
  end

  authbind_port "AuthBind GlassFish Port #{new_resource.admin_port}" do
    only_if { new_resource.admin_port < 1024 }
    port new_resource.admin_port
    user node['glassfish']['user']
  end

  bash "create domain #{new_resource.domain_name}" do
    not_if "#{asadmin_command('list-domains')} #{domain_dir_arg}| grep -- '#{new_resource.domain_name} '"

    args = []
    args << "--instanceport #{new_resource.port}"
    args << "--adminport #{new_resource.admin_port}"
    args << "--nopassword=false" if new_resource.username
    args <<  domain_dir_arg
    command_string = []
    command_string << (requires_authbind ? "authbind --deep " : "") + asadmin_command("create-domain #{args.join(' ')} #{new_resource.domain_name}", false)
    command_string << replace_in_domain_file("%%%CPU_NODE_COUNT%%%", node['cpu'].size - 2)
    command_string << replace_in_domain_file("%%%MAX_PERM_SIZE%%%", new_resource.max_perm_size)
    command_string << replace_in_domain_file("%%%MAX_STACK_SIZE%%%", new_resource.max_stack_size)
    command_string << replace_in_domain_file("%%%MAX_MEM_SIZE%%%", new_resource.max_memory)
    command_string << asadmin_command("verify-domain-xml #{new_resource.domain_name}", false)

    user node['glassfish']['user']
    group node['glassfish']['group']
    code command_string.join("\n")
  end

  file "#{node['glassfish']['domains_dir']}/#{new_resource.domain_name}/docroot/index.html" do
    action :delete
  end

  service "glassfish-#{new_resource.domain_name}" do
    supports :start => true, :restart => true, :stop => true
    action [:start]
  end

  template "#{node['glassfish']['domains_dir']}/#{new_resource.domain_name}/config/logging.properties" do
    source "logging.properties.erb"
    mode "0400"
    cookbook 'glassfish'
    owner node['glassfish']['user']
    group node['glassfish']['group']
    variables(:logging_properties  => default_logging_properties.merge(new_resource.logging_properties))
    notifies :restart, resources(:service => "glassfish-#{new_resource.domain_name}"), :delayed
  end

  template "#{node['glassfish']['domains_dir']}/#{new_resource.domain_name}/config/login.conf" do
    source "login.conf.erb"
    mode "0400"
    cookbook 'glassfish'
    owner node['glassfish']['user']
    group node['glassfish']['group']
    variables(:realm_types  => default_realm_confs.merge(new_resource.realm_types))
    notifies :restart, resources(:service => "glassfish-#{new_resource.domain_name}"), :delayed
  end

  if new_resource.extra_libraries
    new_resource.extra_libraries.each do |extra_library|
      library_location = "#{node['glassfish']['domains_dir']}/#{new_resource.domain_name}/lib/ext/#{::File.basename(extra_library)}"
      remote_file library_location do
        source extra_library
        mode "0640"
        owner node['glassfish']['user']
        group node['glassfish']['group']
        action :create_if_missing
        notifies :restart, resources(:service => "glassfish-#{new_resource.domain_name}"), :immediately
      end
    end
  end

  service "glassfish-#{new_resource.domain_name}" do
    supports :start => true, :restart => true, :stop => true
    action [:start]
  end
end

notifying_action :destroy do
  bash "destroy domain #{new_resource.domain_name}" do
    only_if "#{asadmin_command('list-domains')} #{domain_dir_arg} | grep -- '#{new_resource.domain_name} '"
    command_string = []

    command_string << "#{asadmin_command("stop-domain #{domain_dir_arg} #{new_resource.domain_name}", false)} 2> /dev/null > /dev/null"
    command_string << asadmin_command("delete-domain #{domain_dir_arg} #{new_resource.domain_name}", false)

    user node['glassfish']['user']
    group node['glassfish']['group']
    code command_string.join("\n")
  end
end
