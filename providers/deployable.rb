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

def domain_dir
  "#{node['glassfish']['domains_dir']}/#{new_resource.domain_name}"
end

def version_dir
  "#{domain_dir}/versions"
end

def version_file
  "#{version_dir}/#{new_resource.component_name}"
end

def deployment_plan_dir
  "#{domain_dir}/plans/#{new_resource.component_name}"
end

def archives_dir
  "#{domain_dir}/archives"
end

action :deploy do
  raise 'Must specify url' unless new_resource.url

  cache_present = RealityForge::GlassFish.is_property_cache_present?(node, new_resource.domain_name)
  is_deployed =
    cache_present ?
      RealityForge::GlassFish.any_cached_property_start_with?(node, new_resource.domain_name, "applications.application.#{new_resource.component_name}.") :
      0 != `#{asadmin_command('list-applications')} #{new_resource.target} | grep -- '#{new_resource.component_name} '`.strip.split("\n").size

  plan_version = new_resource.descriptors.empty? ? nil : Asadmin.generate_component_plan_digest(new_resource.descriptors)

  expected_version = "#{new_resource.version_value}#{plan_version ? ":#{plan_version}" : ''}"

  [archives_dir, version_dir].each do |d|
    directory d do
      owner node['glassfish']['user']
      group node['glassfish']['group']
    end
  end

  actual_version = nil
  if is_deployed
    actual_version = ::File.exist?(version_file) ? ::IO.read(version_file) : nil
  end

  if actual_version != expected_version

    Chef::Log.info "Deploying #{new_resource.component_name} from #{new_resource.url}"

    headers = {}
    if new_resource.auth_username and new_resource.auth_password
      headers['Authorization'] = "Basic #{ Base64.encode64("#{new_resource.auth_username}:#{new_resource.auth_password}").gsub("\n", "") }"
    end
    a = glassfish_archive new_resource.component_name do
      prefix archives_dir
      url new_resource.url
      headers headers
      version new_resource.version_value
      owner node['glassfish']['user']
      group node['glassfish']['group']
    end

    deployment_plan = nil
    unless new_resource.descriptors.empty?
      deployment_plan = "#{deployment_plan_dir}/plan-#{plan_version}.jar"
      build_dir = "#{Chef::Config[:file_cache_path]}/glassfish-plan"

      directory deployment_plan_dir do
        recursive true
        action :nothing
        subscribes :delete, "archive[#{new_resource.component_name}]", :immediately
      end

      execute "Create #{deployment_plan}" do
        cmd = <<-CMD
        rm -rf #{build_dir}
        mkdir -p #{build_dir}
        cd #{build_dir}
        CMD
        new_resource.descriptors.collect do |key, file|
          if ::File.dirname(key) != ''
            cmd << "mkdir -p #{::File.dirname(key)}\n"
          end
          cmd << "cp #{file} #{key}\n"
        end
        cmd << <<-CMD
        jar -cf #{deployment_plan} .
        chown #{new_resource.system_user}:#{new_resource.system_group} #{deployment_plan}
        chmod 0700 #{deployment_plan}
        rm -rf #{build_dir}
        test -f #{deployment_plan}
        CMD

        timeout node['glassfish']['asadmin']['timeout'] + 5
        command cmd
        not_if { ::File.exists?(deployment_plan) }
      end
    end

    execute "deploy application #{new_resource.component_name}" do
      args = []
      args << 'deploy'
      args << asadmin_target_flag
      args << '--name' << new_resource.component_name
      args << "--enabled=#{new_resource.enabled}"
      args << '--upload=true' unless node['glassfish']['version'] == '4.1'
      args << '--force=true'
      args << '--type' << new_resource.type if new_resource.type
      args << "--contextroot=#{new_resource.context_root}" if new_resource.context_root
      args << "--generatermistubs=#{new_resource.generate_rmi_stubs}"
      args << "--availabilityenabled=#{new_resource.availability_enabled}"
      args << "--lbenabled=#{new_resource.lb_enabled}"
      args << "--keepstate=#{new_resource.keep_state}"
      args << "--verify=#{new_resource.verify}"
      args << "--precompilejsp=#{new_resource.precompile_jsp}"
      args << "--asyncreplication=#{new_resource.async_replication}"
      args << '--properties' << encode_parameters(new_resource.properties) unless new_resource.properties.empty?
      args << "--virtualservers=#{new_resource.virtual_servers.join(',')}" unless new_resource.virtual_servers.empty?
      args << '--deploymentplan' << deployment_plan if deployment_plan
      args << "--libraries=#{new_resource.libraries.join(',')}" unless new_resource.libraries.empty?
      args << a.target_artifact

      # execute should wait for asadmin to time out first, if it doesn't because of some problem, execute should time out eventually
      timeout node['glassfish']['asadmin']['timeout'] + 5 + 5
      user new_resource.system_user unless node['os'] == 'windows'
      group new_resource.system_group unless node['os'] == 'windows'
      command asadmin_command(args.join(' '))
    end

    file version_file do
      content expected_version
      owner node['glassfish']['user']
      group node['glassfish']['group']
    end
  end
end

action :undeploy do
  cache_present = RealityForge::GlassFish.is_property_cache_present?(node, new_resource.domain_name)
  maybe_deployed =
    cache_present ?
      RealityForge::GlassFish.any_cached_property_start_with?(node, new_resource.domain_name, "applications.application.#{new_resource.component_name}.") :
      true

  if maybe_deployed

    args = []
    args << 'undeploy'
    args << '--cascade=true'
    args << asadmin_target_flag
    args << new_resource.component_name

    execute "asadmin_undeploy #{new_resource.component_name}" do
      unless cache_present
        only_if "#{asadmin_command('list-applications')} #{new_resource.target}| grep -- '#{new_resource.component_name} '", :timeout => node['glassfish']['asadmin']['timeout'] + 5
      end
      # execute should wait for asadmin to time out first, if it doesn't because of some problem, execute should time out eventually
      timeout node['glassfish']['asadmin']['timeout'] + 5 + 5
      user new_resource.system_user unless node['os'] == 'windows'
      group new_resource.system_group unless node['os'] == 'windows'
      command asadmin_command(args.join(' '))
    end

    file version_file do
      action :delete
    end

    directory "#{archives_dir}/#{new_resource.component_name}" do
      recursive true
      action :delete
    end

    directory deployment_plan_dir do
      recursive true
      action :delete
    end
  end
end

action :disable do
  args = []
  args << 'disable'
  args << asadmin_target_flag
  args << new_resource.component_name

  execute "asadmin_disable #{new_resource.component_name}" do
    only_if "#{asadmin_command('list-applications --long')} #{new_resource.target} | grep '#{new_resource.component_name} ' | grep enabled", :timeout => node['glassfish']['asadmin']['timeout'] + 5
    # execute should wait for asadmin to time out first, if it doesn't because of some problem, execute should time out eventually
    timeout node['glassfish']['asadmin']['timeout'] + 5 + 5
    user new_resource.system_user unless node['os'] == 'windows'
    group new_resource.system_group unless node['os'] == 'windows'
    command asadmin_command(args.join(' '))
  end
end

action :enable do
  args = []
  args << 'enable'
  args << asadmin_target_flag
  args << new_resource.component_name

  execute "asadmin_enable #{new_resource.component_name}" do
    not_if "#{asadmin_command('list-applications --long')} #{new_resource.target} | grep #{new_resource.component_name} | grep enabled", :timeout => node['glassfish']['asadmin']['timeout'] + 5
    # execute should wait for asadmin to time out first, if it doesn't because of some problem, execute should time out eventually
    timeout node['glassfish']['asadmin']['timeout'] + 5 + 5
    user new_resource.system_user unless node['os'] == 'windows'
    group new_resource.system_group unless node['os'] == 'windows'
    command asadmin_command(args.join(' '))
  end
end
