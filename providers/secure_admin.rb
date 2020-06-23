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

include Chef::Asadmin

action :enable do
  glassfish_wait_for_glassfish new_resource.domain_name do
    username new_resource.username
    password_file new_resource.password_file
    admin_port new_resource.admin_port
    only_if { new_resource.admin_port }
    action :nothing
  end

  service "glassfish-#{new_resource.domain_name}" do
    supports restart: true, status: true
    timeout 180
    action :nothing
    notifies :run, "glassfish_wait_for_glassfish[#{new_resource.domain_name}]", :immediately
  end

  execute 'asadmin_enable-secure-admin' do
    timeout node['glassfish']['asadmin']['timeout'] + 5
    user new_resource.system_user unless node.windows?
    group new_resource.system_group unless node.windows?
    command asadmin_command('enable-secure-admin', true, secure: false)
    filter = pipe_filter('secure-admin.enabled=true', regexp: false, line: true)
    not_if "#{asadmin_command('get secure-admin.enabled')} | #{filter}", timeout: node['glassfish']['asadmin']['timeout'] + 5

    notifies :restart, "service[glassfish-#{new_resource.domain_name}]", :immediately
  end
end

action :disable do
  service "glassfish-#{new_resource.domain_name}" do
    supports restart: true, status: true
    timeout 180
    action :nothing
  end

  execute 'asadmin_disable-secure-admin' do
    timeout node['glassfish']['asadmin']['timeout'] + 5
    user new_resource.system_user unless node.windows?
    group new_resource.system_group unless node.windows?
    command asadmin_command('disable-secure-admin')
    filter = pipe_filter('secure-admin.enabled=true', regexp: false, line: true)
    only_if "#{asadmin_command('get secure-admin.enabled')} | #{filter}", timeout: node['glassfish']['asadmin']['timeout'] + 5
    notifies :restart, "service[glassfish-#{new_resource.domain_name}]", :immediately
  end
end
