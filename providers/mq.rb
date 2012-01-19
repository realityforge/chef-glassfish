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

  directory "#{instance_dir}/etc" do
    owner node[:glassfish][:user]
    group node[:glassfish][:group]
    mode 0700
    recursive true
  end

  template "/etc/init/omq-#{new_resource.instance}.conf" do
    source "omq-upstart.conf.erb"
    mode "0700"
    cookbook 'glassfish'

    variables(:resource => new_resource,
              :authbind => requires_authbind,
              :vmargs => "-Xmx#{new_resource.max_memory}m -Xss#{new_resource.max_stack_size}k -Djava.util.logging.config.file=#{instance_dir}/etc/logging.properties")
  end

  if requires_authbind
    authbind_port "AuthBind GlassFish OpenMQ Port #{new_resource.port}" do
      port new_resource.port
      user node[:glassfish][:user]
    end
  end

  service "omq-#{new_resource.instance}" do
    provider Chef::Provider::Service::Upstart
    supports :start => true, :restart => true, :stop => true, :status => true
    action [:enable, :start]
  end

  template "#{instance_dir}/etc/logging.properties" do
    source "logging.properties.erb"
    mode "0700"
    cookbook 'glassfish'
    variables(:resource => new_resource)
    notifies :restart, resources(:service => "omq-#{new_resource.instance}")
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
