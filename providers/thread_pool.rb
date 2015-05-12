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
  cache_present = RealityForge::GlassFish.is_property_cache_present?(node, new_resource.domain_name)
  may_need_create =
    cache_present ?
      !RealityForge::GlassFish.any_cached_property_start_with?(node, new_resource.domain_name, "configs.config.server-config.thread-pools.thread-pool.#{new_resource.threadpool_id}") :
      true

  service "glassfish-#{new_resource.domain_name}" do
    supports :restart => true, :status => true
    action :nothing
  end

  if may_need_create

    command = []
    command << 'create-threadpool'
    command << asadmin_target_flag
    command << '--maxthreadpoolsize' << new_resource.maxthreadpoolsize
    command << '--minthreadpoolsize' << new_resource.minthreadpoolsize
    command << '--idletimeout' << new_resource.idletimeout
    command << '--maxqueuesize' << new_resource.maxqueuesize
    command << new_resource.threadpool_id

    bash "asadmin_threadpool #{new_resource.threadpool_id}" do
      unless cache_present
        not_if "#{asadmin_command('list-threadpools')} #{new_resource.target} | grep -F -x -- '#{new_resource.threadpool_id}'", :timeout => 150
      end
      timeout 150
      user new_resource.system_user
      group new_resource.system_group
      code asadmin_command(command.join(' '))
      notifies :restart, "service[glassfish-#{new_resource.domain_name}]", :immediate
    end
  end

  properties = {
    'idle-thread-timeout-seconds' => new_resource.idletimeout,
    'max-queue-size' => new_resource.maxqueuesize,
    'max-thread-pool-size' => new_resource.maxthreadpoolsize,
    'min-thread-pool-size' => new_resource.minthreadpoolsize
  }

  if !cache_present || !may_need_create
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
        notifies :restart, "service[glassfish-#{new_resource.domain_name}]", :delayed
      end
    end
  end
end

action :delete do
  cache_present = RealityForge::GlassFish.is_property_cache_present?(node, new_resource.domain_name)
  may_need_delete =
    cache_present ?
      RealityForge::GlassFish.any_cached_property_start_with?(node, new_resource.domain_name, "configs.config.server-config.thread-pools.thread-pool.#{new_resource.threadpool_id}.") :
      true

  if may_need_delete
    command = []
    command << 'delete-threadpool'
    command << asadmin_target_flag
    command << new_resource.threadpool_id

    bash "asadmin_delete_threadpool #{new_resource.threadpool_id}" do
      unless cache_present
        only_if "#{asadmin_command('list-threadpools')} #{new_resource.target} | grep -F -x -- '#{new_resource.threadpool_id}'", :timeout => 150
      end
      timeout 150
      user new_resource.system_user
      group new_resource.system_group
      code asadmin_command(command.join(' '))
    end
  end
end
