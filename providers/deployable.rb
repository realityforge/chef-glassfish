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

def version_file
  "#{node['glassfish']['domains_dir']}/#{new_resource.domain_name}_#{new_resource.component_name}.VERSION"
end

notifying_action :deploy do
  file version_file do
    owner node['glassfish']['user']
    group node['glassfish']['group']
    mode "0600"
    content new_resource.version.to_s
    action :nothing
  end

  cached_package_filename = "#{Chef::Config[:file_cache_path]}/#{::File.basename(new_resource.url)}"
  remote_file cached_package_filename do
    source new_resource.url
    owner node['glassfish']['user']
    group node['glassfish']['group']
    mode "0600"
    action :create_if_missing
  end

  bash "deploy application #{new_resource.component_name}" do
    not_if "#{asadmin_command('list-applications')} | grep -q -- '#{new_resource.component_name} ' && grep -v -q  '^#{new_resource.version}}$' #{version_file}"

    command = []
    command << "deploy"
    command << "--target" << new_resource.target if new_resource.target
    command << "--name" << new_resource.component_name
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
    command << cached_package_filename

    #TODO  [--deploymentplan deployment_plan]

    user node['glassfish']['user']
    group node['glassfish']['group']
    code asadmin_command(command.join(' '))
    notifies :create, resources(:file => version_file), :immediately
  end
end

notifying_action :undeploy do
  command = []
  command << "undeploy"
  command << "--cascade=true"
  command << "--target" << new_resource.target if new_resource.target
  command << new_resource.component_name

  bash "asadmin_undeploy #{new_resource.component_name}" do
    only_if "#{asadmin_command('list-applications')} | grep -- '#{new_resource.component_name} '"
    user node['glassfish']['user']
    group node['glassfish']['group']
    code asadmin_command(command.join(' '))
  end
end

notifying_action :disable do
  command = []
  command << "disable"
  command << "--target" << new_resource.target if new_resource.target
  command << new_resource.component_name

  bash "asadmin_disable #{new_resource.component_name}" do
    only_if "#{asadmin_command('list-applications --long')} | grep '#{new_resource.component_name} ' | grep enabled"
    user node['glassfish']['user']
    group node['glassfish']['group']
    code asadmin_command(command.join(' '))
  end
end

notifying_action :enable do
  command = []
  command << "enable"
  command << "--target" << new_resource.target if new_resource.target
  command << new_resource.component_name

  bash "asadmin_enable #{new_resource.component_name}" do
    not_if "#{asadmin_command('list-applications --long')} | grep #{new_resource.component_name} | grep enabled"
    user node['glassfish']['user']
    group node['glassfish']['group']
    code asadmin_command(command.join(' '))
  end
end
