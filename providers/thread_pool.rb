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

action :create do
  cache_present = RealityForge::GlassFish.property_cache_present?(node, new_resource.domain_name)
  may_need_create = if cache_present
                      !RealityForge::GlassFish.any_cached_property_start_with?(node, new_resource.domain_name, "configs.config.server-config.thread-pools.thread-pool.#{new_resource.threadpool_id}")
                    else
                      true
                    end

  glassfish_wait_for_glassfish new_resource.domain_name do
    username new_resource.username
    password_file new_resource.password_file
    admin_port new_resource.admin_port
    only_if { new_resource.admin_port }
    action :nothing
  end

  service "glassfish-#{new_resource.domain_name}" do
    supports restart: true, status: true
    action :nothing
    notifies :run, "glassfish_wait_for_glassfish[#{new_resource.domain_name}]", :immediately
  end

  if may_need_create

    args = []
    args << 'create-threadpool'
    args << asadmin_target_flag
    args << '--maxthreadpoolsize' << new_resource.maxthreadpoolsize
    args << '--minthreadpoolsize' << new_resource.minthreadpoolsize
    args << '--idletimeout' << new_resource.idletimeout
    args << '--maxqueuesize' << new_resource.maxqueuesize
    args << new_resource.threadpool_id

    execute "asadmin_threadpool #{new_resource.threadpool_id}" do
      timeout node['glassfish']['asadmin']['timeout'] + 5
      user new_resource.system_user unless node.windows?
      group new_resource.system_group unless node.windows?
      command asadmin_command(args.join(' '))
      unless cache_present
        filter = pipe_filter(new_resource.threadpool_id, regexp: false, line: true)
        not_if "#{asadmin_command('list-threadpools')} #{new_resource.target} | #{filter}", timeout: node['glassfish']['asadmin']['timeout'] + 5
      end
      notifies :restart, "service[glassfish-#{new_resource.domain_name}]", :immediately
    end
  end

  properties = {
    'idle-thread-timeout-seconds' => new_resource.idletimeout,
    'max-queue-size' => new_resource.maxqueuesize,
    'max-thread-pool-size' => new_resource.maxthreadpoolsize,
    'min-thread-pool-size' => new_resource.minthreadpoolsize,
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
  cache_present = RealityForge::GlassFish.property_cache_present?(node, new_resource.domain_name)
  may_need_delete = if cache_present
                      RealityForge::GlassFish.any_cached_property_start_with?(node, new_resource.domain_name, "configs.config.server-config.thread-pools.thread-pool.#{new_resource.threadpool_id}.")
                    else
                      true
                    end

  if may_need_delete
    args = []
    args << 'delete-threadpool'
    args << asadmin_target_flag
    args << new_resource.threadpool_id

    execute "asadmin_delete_threadpool #{new_resource.threadpool_id}" do
      timeout node['glassfish']['asadmin']['timeout'] + 5
      user new_resource.system_user unless node.windows?
      group new_resource.system_group unless node.windows?
      command asadmin_command(args.join(' '))
      unless cache_present
        filter = pipe_filter(new_resource.threadpool_id, regexp: false, line: true)
        only_if "#{asadmin_command('list-threadpools')} #{new_resource.target} | #{filter}", timeout: node['glassfish']['asadmin']['timeout'] + 5
      end
    end
  end
end
