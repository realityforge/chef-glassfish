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

# TODO: Configure the hostname on which the services run.
# See http://docs.oracle.com/cd/E19148-01/819-4467/aeont/index.html and hostname
# properties. The glassfish_mq_ensure_running should also be adapted to use this
# configuration

def mq_config_settings(resource)
  configs = {}
  configs['imq.log.timezone'] = node['tz'] || 'GMT'

  # Specify supported LogHandlers
  configs['imq.log.handlers'] = 'file,console'

  # FileLogHandler settings.
  # The FileLogHandler logs messages to a set of rolling files.
  # The rollover criteria can be the file size (bytes) and/or
  # the file age (seconds). 0 means don't rollover based on that criteria.
  configs['imq.log.file.rolloverbytes'] = '268435456'
  configs['imq.log.file.rolloversecs'] = '604800'
  configs['imq.log.file.dirpath'] = '${imq.instanceshome}${/}${imq.instancename}${/}log'
  configs['imq.log.file.filename'] = 'omq.log'
  configs['imq.log.file.output'] = 'ERROR|WARNING'

  # Console settings.
  # The console handler logs messages to an OutputStream. This can either be
  # System.err (ERR) or System.out (OUT).
  configs['imq.log.console.stream'] = 'ERR'
  configs['imq.log.console.output'] = 'ERROR|WARNING'

  configs.merge!(resource.config)

  bridges = []
  services = []

  configs['imq.portmapper.port'] = resource.port

  if resource.admin_port
    services << 'admin'
    configs['imq.admin.tcp.port'] = resource.admin_port
  end

  if resource.jms_port
    services << 'jms'
    configs['imq.jms.tcp.port'] = resource.jms_port
  end

  if resource.stomp_port
    bridges << 'stomp'
    configs['imq.bridge.stomp.tcp.enabled'] = 'true'
    configs['imq.bridge.stomp.tcp.port'] = resource.stomp_port
    configs['imq.bridge.stomp.logfile.limit'] = '268435456'
    configs['imq.bridge.stomp.logfile.count'] = '3'
  end

  configs['imq.service.activelist'] = services.join(',') unless services.size.empty?

  configs['imq.bridge.admin.user'] = resource.admin_user
  user = resource.users[resource.admin_user]
  raise "Missing user details for admin user '#{resource.admin_user}'" unless user
  configs['imq.bridge.admin.password'] = user['password']
  configs['imq.imqcmd.password'] = user['password']

  unless bridges.size.empty?
    configs['imq.bridge.enabled'] = 'true'
    configs['imq.bridge.activelist'] = bridges.join(',')
  end

  configs
end

action :create do
  service_name = "omq-#{new_resource.instance}"
  service_resource_name = new_resource.init_style == 'upstart' ? "service[#{service_name}]" : "runit_service[#{service_name}]"

  requires_authbind = false
  requires_authbind ||= new_resource.port < 1024
  requires_authbind ||= new_resource.admin_port < 1024
  requires_authbind ||= new_resource.jms_port < 1024
  requires_authbind ||= new_resource.jmx_port < 1024
  requires_authbind ||= (new_resource.stomp_port && new_resource.stomp_port < 1024)

  listen_ports = [new_resource.port]
  listen_ports << new_resource.jmx_port if new_resource.jmx_port
  listen_ports << new_resource.admin_port if new_resource.admin_port
  listen_ports << new_resource.jms_port if new_resource.jms_port
  listen_ports << new_resource.stomp_port if new_resource.stomp_port

  instance_dir = "#{node['openmq']['var_home']}/instances/#{new_resource.instance}"
  passfile = "#{instance_dir}/props/config.properties"

  directory node['openmq']['var_home'] do
    recursive true
    owner new_resource.system_user unless node.windows?
    group new_resource.system_group unless node.windows?
    mode '0700'
  end

  directory "#{node['openmq']['var_home']}/instances" do
    owner new_resource.system_user unless node.windows?
    group new_resource.system_group unless node.windows?
    mode '0700'
  end

  %W(#{instance_dir} #{instance_dir}/etc #{instance_dir}/log #{instance_dir}/props #{instance_dir}/bin).each do |dir|
    directory dir do
      owner new_resource.system_user unless node.windows?
      group new_resource.system_group unless node.windows?
      mode '0700'
    end
  end

  # Not sure why this is required... but something runs service as root which created this file as root owned
  file "#{instance_dir}/log/log.txt" do
    not_if { ::File.exist?("#{instance_dir}/log/log.txt") }
    owner new_resource.system_user unless node.windows?
    group new_resource.system_group unless node.windows?
    mode '0700'
    action :touch
  end

  file "#{instance_dir}/bin/#{new_resource.instance}_imqcmd" do
    mode '0700'
    owner new_resource.system_user unless node.windows?
    group new_resource.system_group unless node.windows?
    content <<-SH
#!/bin/sh

#{Imqcmd.imqcmd_command(node, '"$@"', host: '127.0.0.1', port: new_resource.port, username: new_resource.admin_user, passfile: passfile)}
    SH
  end

  vm_args = []
  vm_args << "-Xmx#{new_resource.max_memory}m"
  vm_args << "-Xss#{new_resource.max_stack_size}k"
  vm_args << "-Djava.util.logging.config.file=#{instance_dir}/etc/logging.properties"
  if new_resource.jmx_port
    vm_args << '-Dcom.sun.management.jmxremote'
    vm_args << "-Dcom.sun.management.jmxremote.port=#{new_resource.jmx_port}"
    vm_args << "-Dcom.sun.management.jmxremote.rmi.port=#{new_resource.rmi_port}" if new_resource.rmi_port
    vm_args << "-Djava.rmi.server.hostname=#{node['fqdn']}"
    vm_args << "-Dcom.sun.management.jmxremote.access.file=#{instance_dir}/etc/jmxremote.access"
    vm_args << "-Dcom.sun.management.jmxremote.password.file=#{instance_dir}/etc/jmxremote.password"
    vm_args << '-Dcom.sun.management.jmxremote.ssl=false'
  end

  if new_resource.port < 1024
    authbind_port "AuthBind GlassFish OpenMQ Port #{new_resource.port}" do
      port new_resource.port
      user new_resource.system_user
      not_if { os.windows? }
    end
  end

  if new_resource.jmx_port && new_resource.jmx_port < 1024
    authbind_port "AuthBind GlassFish OpenMQ JMX Port #{new_resource.jmx_port}" do
      port new_resource.jmx_port
      user new_resource.system_user
      not_if { os.windows? }
    end
  end

  if new_resource.rmi_port && new_resource.rmi_port < 1024
    authbind_port "AuthBind GlassFish OpenMQ RMI Port #{new_resource.rmi_port}" do
      port new_resource.rmi_port
      user new_resource.system_user
      not_if { os.windows? }
    end
  end

  if new_resource.admin_port && new_resource.admin_port < 1024
    authbind_port "AuthBind GlassFish OpenMQ Admin Port #{new_resource.admin_port}" do
      port new_resource.admin_port
      user new_resource.system_user
      not_if { os.windows? }
    end
  end

  if new_resource.jms_port && new_resource.jms_port < 1024
    authbind_port "AuthBind GlassFish OpenMQ JMS Port #{new_resource.jms_port}" do
      port new_resource.jms_port
      user new_resource.system_user
      not_if { os.windows? }
    end
  end

  if new_resource.stomp_port && new_resource.stomp_port < 1024
    authbind_port "AuthBind GlassFish OpenMQ Stomp Port #{new_resource.stomp_port}" do
      port new_resource.stomp_port
      user new_resource.system_user
      not_if { os.windows? }
    end
  end

  if new_resource.init_style == 'upstart'
    template "/etc/init/#{service_name}.conf" do
      source 'omq-upstart.conf.erb'
      mode '0644'
      cookbook 'glassfish'

      variables(resource: new_resource,
                authbind: requires_authbind,
                vmargs: vm_args.join(' '))
    end

    service service_name do
      provider Chef::Provider::Service::Upstart
      supports start: true, restart: true, stop: true, status: true
      action [:enable]
    end
  elsif new_resource.init_style == 'runit'
    runit_service service_name do
      default_logger true
      check true
      cookbook 'glassfish'
      run_template_name 'omq'
      check_script_template_name 'omq'
      options(instance_dir: instance_dir,
              instance_name: new_resource.instance,
              authbind: requires_authbind,
              vmargs: vm_args.join(' '),
              listen_ports: listen_ports)
      sv_timeout 300
      action [:nothing]
    end
  else
    raise "Unknown init style #{new_resource.init_style}"
  end

  if new_resource.jmx_port
    file "#{instance_dir}/etc/jmxremote.access" do
      owner new_resource.system_user unless node.windows?
      group new_resource.system_group unless node.windows?
      mode '0400'
      action :create
      content (new_resource.jmx_admins.keys.sort.collect { |username| "#{username}=readwrite\n" } + new_resource.jmx_monitors.keys.sort.collect { |username| "#{username}=readonly\n" }).join('') # rubocop:disable Lint/ParenthesesAsGroupedExpression
      notifies :restart, service_resource_name, :delayed
    end

    file "#{instance_dir}/etc/jmxremote.password" do
      owner new_resource.system_user unless node.windows?
      group new_resource.system_group unless node.windows?
      mode '0400'
      action :create
      content (new_resource.jmx_admins.sort.collect { |username, password| "#{username}=#{password}\n" } + new_resource.jmx_monitors.sort.collect { |username, password| "#{username}=#{password}\n" }).join('') # rubocop:disable Lint/ParenthesesAsGroupedExpression
      notifies :restart, service_resource_name, :delayed
    end
  end

  template passfile do
    not_if do
      properties = {}
      filename = passfile
      keep_existing = false
      if ::File.exist?(filename)
        IO.foreach(filename) do |line|
          properties[Regexp.last_match(1).strip] = Regexp.last_match(2) if line =~ /([^#=]+)=(.*)/
        end
        keep_existing = true
        mq_config_settings(new_resource).each do |k, v|
          keep_existing = false if properties[k].to_s != v.to_s
        end
      end
      keep_existing
    end
    source 'config.properties.erb'
    mode '0600'
    cookbook 'glassfish'
    owner new_resource.system_user unless node.windows?
    group new_resource.system_group unless node.windows?
    variables(configs: mq_config_settings(new_resource))
    notifies :restart, service_resource_name, :delayed
  end

  template "#{instance_dir}/etc/logging.properties" do
    source 'logging.properties.erb'
    mode '0400'
    cookbook 'glassfish'
    owner new_resource.system_user unless node.windows?
    group new_resource.system_group unless node.windows?
    variables(logging_properties: new_resource.logging_properties)
    notifies :restart, service_resource_name, :delayed
  end

  template "#{instance_dir}/etc/passwd" do
    source 'passwd.erb'
    mode '0400'
    cookbook 'glassfish'
    owner new_resource.system_user unless node.windows?
    group new_resource.system_group unless node.windows?
    variables(users: new_resource.users)
  end

  template "#{instance_dir}/etc/accesscontrol.properties" do
    source 'accesscontrol.properties.erb'
    mode '0400'
    cookbook 'glassfish'
    owner new_resource.system_user unless node.windows?
    group new_resource.system_group unless node.windows?
    variables(rules: new_resource.access_control_rules)
  end

  ruby_block service_resource_name do
    block do
      s = run_context.resource_collection.lookup(service_resource_name)
      s.run_action(:enable)
      s.run_action(:start)
    end
  end

  destinations = {}
  destinations.merge!(new_resource.queues)
  destinations.merge!(new_resource.topics)

  listen_ports.each do |listen_port|
    glassfish_mq_ensure_running "#{service_resource_name} - #{node['fqdn']}:#{listen_port} - wait for initialization" do
      host node['fqdn']
      port listen_port
    end
  end

  destinations.each_pair do |key, config|
    glassfish_mq_destination key do
      queue new_resource.queues.keys.include?(key)
      config config
      host '127.0.0.1'
      port new_resource.port
      username new_resource.admin_user
      passfile passfile
    end
  end
end

action :destroy do
  service_name = "omq-#{new_resource.instance}"

  if new_resource.init_style == 'upstart'
    service service_name do
      provider Chef::Provider::Service::Upstart
      supports start: true, restart: true, stop: true, status: true
      action [:stop, :disable]
    end

    file "/etc/init/omq-#{new_resource.instance}.conf" do
      action :delete
    end
  elsif new_resource.init_style == 'runit'
    runit_service service_name do
      action [:stop, :disable]
    end
  else
    raise "Unknown init style #{new_resource.init_style}"
  end
end
