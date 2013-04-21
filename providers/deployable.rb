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
require 'digest/sha1'

include Chef::Asadmin

use_inline_resources

def versioned_name
  @deployed_name ||= Asadmin.versioned_component_name(new_resource.component_name, new_resource.type, new_resource.version, new_resource.url, new_resource.descriptors)
end

action :deploy do
  raise "Must specify url" unless new_resource.url

  version_value = new_resource.version ? new_resource.version.to_s : Digest::SHA1.hexdigest(new_resource.url)
  base_cache_name = "#{Chef::Config[:file_cache_path]}/#{new_resource.domain_name}_#{new_resource.component_name}_#{version_value}"

  check_command = "#{asadmin_command('list-applications')} #{new_resource.target} | grep -q -- '#{versioned_name} '"

  cached_package_filename = nil
  if new_resource.url =~ /^file\:\/\//
    cached_package_filename = new_resource.url[7, new_resource.url.length]
  else
    cached_package_filename = "#{base_cache_name}#{::File.extname(new_resource.url)}"
    remote_file cached_package_filename do
      not_if check_command
      source new_resource.url
      owner node['glassfish']['user']
      group node['glassfish']['group']
      mode "0600"
      action :create_if_missing
    end
  end

  deployment_plan = nil
  unless new_resource.descriptors.empty?
    plan_digest = Asadmin.generate_component_plan_digest(new_resource.descriptors)
    deployment_plan = "#{base_cache_name}-deployment-plan.#{plan_digest}.jar"
    deployment_plan_dir = "#{Chef::Config[:file_cache_path]}/#{::File.basename(deployment_plan, '.jar')}"

    bash "Create #{deployment_plan}" do
      command = <<-CMD
rm -rf #{deployment_plan_dir}
mkdir -p #{deployment_plan_dir}
cd #{deployment_plan_dir}
      CMD
      new_resource.descriptors.collect do |key, file|
        if ::File.dirname(key) != ''
          command << "mkdir -p #{::File.dirname(key)}\n"
        end
        command << "cp #{file} #{key}\n"
      end
      command << <<-CMD
jar -cf #{deployment_plan} .
chown #{node['glassfish']['user']}:#{node['glassfish']['group']} #{deployment_plan}
chmod 0700 #{deployment_plan}
rm -rf #{deployment_plan_dir}
test -f #{deployment_plan}
      CMD
      code command
      not_if { ::File.exists?(deployment_plan) }
    end
  end

  bash "deploy application #{versioned_name}" do
    not_if check_command

    command = []
    command << "deploy"
    command << asadmin_target_flag
    command << "--name" << versioned_name
    command << "--enabled=#{new_resource.enabled}"
    command << "--upload=true"
    command << "--force=true"
    command << "--type" << new_resource.type if new_resource.type
    command << "--contextroot=#{new_resource.context_root}" if new_resource.context_root
    command << "--generatermistubs=#{new_resource.generate_rmi_stubs}"
    command << "--availabilityenabled=#{new_resource.availability_enabled}"
    command << "--lbenabled=#{new_resource.lb_enabled}"
    command << "--keepstate=#{new_resource.keep_state}"
    command << "--verify=#{new_resource.verify}"
    command << "--precompilejsp=#{new_resource.precompile_jsp}"
    command << "--asyncreplication=#{new_resource.async_replication}"
    command << "--properties" << encode_parameters(new_resource.properties) unless new_resource.properties.empty?
    command << "--virtualservers=#{new_resource.virtual_servers.join(",")}" unless new_resource.virtual_servers.empty?
    command << "--deploymentplan" << deployment_plan if deployment_plan
    command << cached_package_filename

    user node['glassfish']['user']
    group node['glassfish']['group']
    code asadmin_command(command.join(' '))
  end
end

action :undeploy do
  command = []
  command << "undeploy"
  command << "--cascade=true"
  command << asadmin_target_flag
  command << versioned_name

  bash "asadmin_undeploy #{versioned_name}" do
    only_if "#{asadmin_command('list-applications')} #{new_resource.target}| grep -- '#{versioned_name} '"
    user node['glassfish']['user']
    group node['glassfish']['group']
    code asadmin_command(command.join(' '))
  end
end

action :disable do
  command = []
  command << "disable"
  command << asadmin_target_flag
  command << versioned_name

  bash "asadmin_disable #{versioned_name}" do
    only_if "#{asadmin_command('list-applications --long')} #{new_resource.target} | grep '#{versioned_name} ' | grep enabled"
    user node['glassfish']['user']
    group node['glassfish']['group']
    code asadmin_command(command.join(' '))
  end
end

action :enable do
  command = []
  command << "enable"
  command << asadmin_target_flag
  command << versioned_name

  bash "asadmin_enable #{versioned_name}" do
    not_if "#{asadmin_command('list-applications --long')} #{new_resource.target} | grep #{versioned_name} | grep enabled"
    user node['glassfish']['user']
    group node['glassfish']['group']
    code asadmin_command(command.join(' '))
  end
end
