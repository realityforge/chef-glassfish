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

action :create do
  if new_resource.init_style == 'upstart'
    service "glassfish-#{new_resource.domain_name}" do
      provider Chef::Provider::Service::Upstart
      supports :restart => true, :status => true
      action :nothing
    end
  elsif new_resource.init_style == 'runit'
    runit_service "glassfish-#{new_resource.domain_name}" do
      sv_timeout 100
      supports :restart => true, :status => true
      action :nothing
    end
  else
    raise "Unknown init style #{new_resource.init_style}"
  end

  command = []
  command << "create-threadpool"
  command << asadmin_target_flag
  command << '--maxthreadpoolsize' << new_resource.maxthreadpoolsize
  command << '--minthreadpoolsize' << new_resource.minthreadpoolsize
  command << '--idletimeout' << new_resource.idletimeout
  command << '--maxqueuesize' << new_resource.maxqueuesize
  command << new_resource.threadpool_id

  bash "asadmin_threadpool #{new_resource.threadpool_id}" do
    not_if "#{asadmin_command('list-threadpools')} #{new_resource.target} | grep -x -- '#{new_resource.threadpool_id}'"
    user new_resource.system_user
    group new_resource.system_group
    code asadmin_command(command.join(' '))
    notifies :restart, "service[glassfish-#{new_resource.domain_name}]", :immediate if new_resource.init_style == 'upstart'
    notifies :restart, "runit_service[glassfish-#{new_resource.domain_name}]", :immediate if new_resource.init_style == 'runit'
  end

  properties = {
    'idle-thread-timeout-seconds' => new_resource.idletimeout,
    'max-queue-size' => new_resource.maxqueuesize,
    'max-thread-pool-size' => new_resource.maxthreadpoolsize,
    'min-thread-pool-size' => new_resource.minthreadpoolsize
  }

  properties.each_pair do |key, value|
    variable = "configs.config.server-config.thread-pools.thread-pool.#{new_resource.threadpool_id}.#{key}"
    glassfish_property "#{variable}=#{value}" do
      domain_name new_resource.domain_name
      admin_port new_resource.admin_port
      username new_resource.username
      password_file new_resource.password_file
      secure new_resource.secure
      key variable
      value value.to_s
      notifies :restart, "service[glassfish-#{new_resource.domain_name}]", :delayed if new_resource.init_style == 'upstart'
      notifies :restart, "runit_service[glassfish-#{new_resource.domain_name}]", :delayed if new_resource.init_style == 'runit'
    end
  end
end

action :delete do
  command = []
  command << "delete-threadpool"
  command << asadmin_target_flag
  command << new_resource.threadpool_id

  bash "asadmin_delete_threadpool #{new_resource.threadpool_id}" do
    only_if "#{asadmin_command('list-threadpools')} #{new_resource.target} | grep -x -- '#{new_resource.threadpool_id}'"
    user new_resource.system_user
    group new_resource.system_group
    code asadmin_command(command.join(' '))
  end
end
