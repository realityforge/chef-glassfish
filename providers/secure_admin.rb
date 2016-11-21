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

use_inline_resources

action :enable do
  service "glassfish-#{new_resource.domain_name}" do
    supports :restart => true, :status => true
    action :nothing
  end

  execute 'asadmin_enable-secure-admin' do
    # bash should wait for asadmin to time out first, if it doesn't because of some problem, bash should time out eventually
    timeout node['glassfish']['asadmin']['timeout'] + 5

    user new_resource.system_user unless node[:os] == 'windows'
    group new_resource.system_group unless node[:os] == 'windows'
    command asadmin_command('enable-secure-admin', true, :secure => false)

    filter = pipe_filter('secure-admin.enabled=true', regexp: false, line: true)
    not_if "#{asadmin_command('get secure-admin.enabled')} | #{filter}", :timeout => node['glassfish']['asadmin']['timeout'] + 5

    notifies :restart, "service[glassfish-#{new_resource.domain_name}]", :immediate
  end
end

action :disable do
  service "glassfish-#{new_resource.domain_name}" do
    supports :restart => true, :status => true
    action :nothing
  end

  execute 'asadmin_disable-secure-admin' do
    # bash should wait for asadmin to time out first, if it doesn't because of some problem, bash should time out eventually
    timeout node['glassfish']['asadmin']['timeout'] + 5
    user new_resource.system_user unless node[:os] == 'windows'
    group new_resource.system_group unless node[:os] == 'windows'
    command asadmin_command('disable-secure-admin')

    filter = pipe_filter('secure-admin.enabled=true', regexp: false, line: true)
    only_if "#{asadmin_command('get secure-admin.enabled')} | #{filter}", :timeout => node['glassfish']['asadmin']['timeout'] + 5

    notifies :restart, "service[glassfish-#{new_resource.domain_name}]", :immediate
  end
end
