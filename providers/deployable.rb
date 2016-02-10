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

  directory version_dir do
    owner node['glassfish']['user']
    group node['glassfish']['group']
  end

  actual_version = nil
  if is_deployed
    actual_version = ::File.exist?(version_file) ? ::IO.read(version_file) : nil
  end

  if actual_version != expected_version

    Chef::Log.info "Deploying #{new_resource.component_name} from #{new_resource.url}"

    a = archive new_resource.component_name do
      prefix archives_dir
      url new_resource.url
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

      bash "Create #{deployment_plan}" do
        command = <<-CMD
        rm -rf #{build_dir}
        mkdir -p #{build_dir}
        cd #{build_dir}
        CMD
        new_resource.descriptors.collect do |key, file|
          if ::File.dirname(key) != ''
            command << "mkdir -p #{::File.dirname(key)}\n"
          end
          command << "cp #{file} #{key}\n"
        end
        command << <<-CMD
        jar -cf #{deployment_plan} .
        chown #{new_resource.system_user}:#{new_resource.system_group} #{deployment_plan}
        chmod 0700 #{deployment_plan}
        rm -rf #{build_dir}
        test -f #{deployment_plan}
        CMD

        timeout 150
        code command
        not_if { ::File.exists?(deployment_plan) }
      end
    end

    bash "deploy application #{new_resource.component_name}" do
      command = []
      command << 'deploy'
      command << asadmin_target_flag
      command << '--name' << new_resource.component_name
      command << "--enabled=#{new_resource.enabled}"
      command << '--upload=true' unless node['glassfish']['version'] == '4.1'
      command << '--force=true'
      command << '--type' << new_resource.type if new_resource.type
      command << "--contextroot=#{new_resource.context_root}" if new_resource.context_root
      command << "--generatermistubs=#{new_resource.generate_rmi_stubs}"
      command << "--availabilityenabled=#{new_resource.availability_enabled}"
      command << "--lbenabled=#{new_resource.lb_enabled}"
      command << "--keepstate=#{new_resource.keep_state}"
      command << "--verify=#{new_resource.verify}"
      command << "--precompilejsp=#{new_resource.precompile_jsp}"
      command << "--asyncreplication=#{new_resource.async_replication}"
      command << '--properties' << encode_parameters(new_resource.properties) unless new_resource.properties.empty?
      command << "--virtualservers=#{new_resource.virtual_servers.join(',')}" unless new_resource.virtual_servers.empty?
      command << '--deploymentplan' << deployment_plan if deployment_plan
      command << "--libraries=#{new_resource.libraries.join(',')}" unless new_resource.libraries.empty?
      command << a.target_artifact

      # bash should wait for asadmin to time out first, if it doesn't because of some problem, bash should time out eventually
      timeout node['glassfish']['asadmin']['timeout'] + 5
      user new_resource.system_user
      group new_resource.system_group
      code asadmin_command(command.join(' '))
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

    command = []
    command << 'undeploy'
    command << '--cascade=true'
    command << asadmin_target_flag
    command << new_resource.component_name

    bash "asadmin_undeploy #{new_resource.component_name}" do
      unless cache_present
        only_if "#{asadmin_command('list-applications')} #{new_resource.target}| grep -- '#{new_resource.component_name} '", :timeout => node['glassfish']['asadmin']['timeout']
      end
      # bash should wait for asadmin to time out first, if it doesn't because of some problem, bash should time out eventually
      timeout node['glassfish']['asadmin']['timeout'] + 5
      user new_resource.system_user
      group new_resource.system_group
      code asadmin_command(command.join(' '))
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
  command = []
  command << 'disable'
  command << asadmin_target_flag
  command << new_resource.component_name

  bash "asadmin_disable #{new_resource.component_name}" do
    only_if "#{asadmin_command('list-applications --long')} #{new_resource.target} | grep '#{new_resource.component_name} ' | grep enabled", :timeout => node['glassfish']['asadmin']['timeout']
    # bash should wait for asadmin to time out first, if it doesn't because of some problem, bash should time out eventually
    timeout node['glassfish']['asadmin']['timeout'] + 5
    user new_resource.system_user
    group new_resource.system_group
    code asadmin_command(command.join(' '))
  end
end

action :enable do
  command = []
  command << 'enable'
  command << asadmin_target_flag
  command << new_resource.component_name

  bash "asadmin_enable #{new_resource.component_name}" do
    not_if "#{asadmin_command('list-applications --long')} #{new_resource.target} | grep #{new_resource.component_name} | grep enabled", :timeout => node['glassfish']['asadmin']['timeout']
    # bash should wait for asadmin to time out first, if it doesn't because of some problem, bash should time out eventually
    timeout node['glassfish']['asadmin']['timeout'] + 5
    user new_resource.system_user
    group new_resource.system_group
    code asadmin_command(command.join(' '))
  end
end
