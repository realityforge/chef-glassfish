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

  template "/etc/init/omq-#{new_resource.name}.conf" do
    source "omq-upstart.conf.erb"
    mode "0700"
    cookbook 'glassfish'

    variables(:name => new_resource.name,
              :authbind => requires_authbind,
              :vmargs => "-Xmx#{new_resource.max_memory}m -Xss#{new_resource.max_stack_size}k",
              :port => new_resource.port,
              :var_home => new_resource.var_home)
  end

  if requires_authbind
    authbind_port "AuthBind GlassFish OpenMQ Port #{new_resource.port}" do
      port new_resource.port
      user node[:glassfish][:user]
    end
  end

  service "omq-#{new_resource.name}" do
    provider Chef::Provider::Service::Upstart
    supports :start => true, :restart => true, :stop => true, :status => true
    action [:enable, :start]
  end
end

action :destroy do
  service "omq-#{new_resource.name}" do
    action [:stop]
  end

  file "/etc/init/omq-#{new_resource.name}.conf" do
    action :delete
  end
end
