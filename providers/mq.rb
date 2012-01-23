#
# Cookbook Name:: glassfish
# Recipe:: default
#
# Copyright 2011, Peter Donald
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

action :create do
  requires_authbind = new_resource.port < 1024

  instance_dir = "#{new_resource.var_home}/instances/#{new_resource.instance}"

  directory new_resource.var_home do
    owner node[:glassfish][:user]
    group node[:glassfish][:group]
    mode 0700
  end

  directory "#{new_resource.var_home}/instances" do
    owner node[:glassfish][:user]
    group node[:glassfish][:group]
    mode 0700
  end

  directory instance_dir do
    owner node[:glassfish][:user]
    group node[:glassfish][:group]
    mode 0700
  end

  directory "#{instance_dir}/etc" do
    owner node[:glassfish][:user]
    group node[:glassfish][:group]
    mode 0700
  end

  file "#{instance_dir}/etc/passwd" do
    owner node[:glassfish][:user]
    group node[:glassfish][:group]
    mode 0700
    action :touch
  end

  directory "#{instance_dir}/log" do
    owner node[:glassfish][:user]
    group node[:glassfish][:group]
    mode 0700
  end

  # Not sure why this is required... but something runs service as root which created this file as root owned
  file "#{instance_dir}/log/log.txt" do
    owner node[:glassfish][:user]
    group node[:glassfish][:group]
    mode 0700
    action :touch
  end

  directory "#{instance_dir}/props" do
    owner node[:glassfish][:user]
    group node[:glassfish][:group]
    mode 0700
  end

  vm_args = []
  vm_args << "-Xmx#{new_resource.max_memory}m"
  vm_args << "-Xss#{new_resource.max_stack_size}k"
  vm_args << "-Djava.util.logging.config.file=#{instance_dir}/etc/logging.properties"
  if new_resource.jmx_port
    vm_args << "-Dcom.sun.management.jmxremote"
    vm_args << "-Dcom.sun.management.jmxremote.port=#{new_resource.jmx_port}"
    vm_args << "-Dcom.sun.management.jmxremote.access.file=#{instance_dir}/etc/jmxremote.access"
    vm_args << "-Dcom.sun.management.jmxremote.password.file=#{instance_dir}/etc/jmxremote.password"
    vm_args << "-Dcom.sun.management.jmxremote.ssl=false"
  end

  template "/etc/init/omq-#{new_resource.instance}.conf" do
    source "omq-upstart.conf.erb"
    mode "0644"
    cookbook 'glassfish'

    variables(:resource => new_resource,
              :authbind => requires_authbind,
              :vmargs => vm_args.join(" "))
  end

  if new_resource.port < 1024
    authbind_port "AuthBind GlassFish OpenMQ Port #{new_resource.port}" do
      port new_resource.port
      user node[:glassfish][:user]
    end
  end

  if new_resource.jmx_port && new_resource.jmx_port < 1024
    authbind_port "AuthBind GlassFish OpenMQ JMX Port #{new_resource.jmx_port}" do
      port new_resource.jmx_port
      user node[:glassfish][:user]
    end
  end

  service "omq-#{new_resource.instance}" do
    provider Chef::Provider::Service::Upstart
    supports :start => true, :restart => true, :stop => true, :status => true
    action [:enable, :start]
  end

  if new_resource.jmx_port
    admins = {}
    search(:users, "groups:#{new_resource.admin_group} AND jmx_password:*") do |u|
      admins[u['id']] = u['jmx_password']
    end
    monitors = {}
    search(:users, "groups:#{new_resource.monitor_group} AND jmx_password:*") do |u|
      monitors[u['id']] = u['jmx_password']
    end

    file "#{instance_dir}/etc/jmxremote.access" do
      owner node[:glassfish][:user]
      group node[:glassfish][:group]
      mode "0400"
      action :create
      content (admins.keys.collect { |username| "#{username}=readwrite\n" } + monitors.keys.collect { |username| "#{username}=readonly\n" }).join("")
      notifies :restart, resources(:service => "omq-#{new_resource.instance}"), :delayed
    end

    file "#{instance_dir}/etc/jmxremote.password" do
      owner node[:glassfish][:user]
      group node[:glassfish][:group]
      mode "0400"
      action :create
      content (admins.collect { |username, password| "#{username}=#{password}\n" } + monitors.collect { |username, password| "#{username}=#{password}\n" }).join("")
      notifies :restart, resources(:service => "omq-#{new_resource.instance}"), :delayed
    end
  end

  file "#{instance_dir}/props/config.properties" do
    owner node[:glassfish][:user]
    group node[:glassfish][:group]
    mode "0400"
    action :create
    content "imq.instanceconfig.version=300\n#{new_resource.config.collect { |k, v| "#{k}=#{v}\n" }.join("")}"
    notifies :restart, resources(:service => "omq-#{new_resource.instance}"), :delayed
  end

  template "#{instance_dir}/etc/logging.properties" do
    source "logging.properties.erb"
    mode "0400"
    cookbook 'glassfish'
    variables(:resource => new_resource)
    notifies :restart, resources(:service => "omq-#{new_resource.instance}"), :delayed
  end

  template "#{instance_dir}/etc/accesscontrol.properties" do
    source "accesscontrol.properties.erb"
    mode "0400"
    cookbook 'glassfish'
    variables(:rules => new_resource.access_control_rules)
    notifies :restart, resources(:service => "omq-#{new_resource.instance}"), :delayed
  end
end

action :destroy do
  service "omq-#{new_resource.instance}" do
    action [:stop]
  end

  file "/etc/init/omq-#{new_resource.instance}.conf" do
    action :delete
  end
end
