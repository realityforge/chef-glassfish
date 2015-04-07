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

  bash 'asadmin_enable-secure-admin' do
    not_if "#{asadmin_command('get secure-admin.enabled')} | grep -F -x -- 'secure-admin.enabled=true'", :timeout => 150
    timeout 150
    user new_resource.system_user
    group new_resource.system_group
    code asadmin_command('enable-secure-admin', true, :secure => false)
    notifies :restart, "service[glassfish-#{new_resource.domain_name}]", :immediate
  end
end

action :disable do
  service "glassfish-#{new_resource.domain_name}" do
    supports :restart => true, :status => true
    action :nothing
  end

  bash 'asadmin_disable-secure-admin' do
    only_if "#{asadmin_command('get secure-admin.enabled')} | grep -F -x -- 'secure-admin.enabled=true'", :timeout => 150
    timeout 150
    user new_resource.system_user
    group new_resource.system_group
    code asadmin_command('disable-secure-admin')
    notifies :restart, "service[glassfish-#{new_resource.domain_name}]", :immediate
  end
end
