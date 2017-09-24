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
      !RealityForge::GlassFish.any_cached_property_start_with?(node, new_resource.domain_name, "resources.jdbc-connection-pool.#{new_resource.name}.") :
      true

  parameters = {:restype => 'res-type',
                :isolationlevel => 'transaction-isolation-level',
                :validationmethod => 'connection-validation-method'}
  Chef::ResourceResolver.resolve(:glassfish_jdbc_connection_pool)::ATTRIBUTES.each do |attr|
    parameters[attr.key] = attr.arg
  end

  if may_need_create
    args = []
    args << 'create-jdbc-connection-pool'
    parameters.each_key do |key|
      args << "--#{key}=#{new_resource.send(key)}" if new_resource.send(key)
    end

    args << '--property' << encode_parameters(new_resource.properties) unless new_resource.properties.empty?
    args << '--description' << "'#{new_resource.description}'" if new_resource.description
    args << new_resource.name

    execute "asadmin_create_jdbc_connection_pool #{new_resource.name}" do
      unless cache_present
        not_if "#{asadmin_command('list-jdbc-connection-pools')} | grep -F -x -- '#{new_resource.name}'", :timeout => node['glassfish']['asadmin']['timeout'] + 5
      end
      timeout node['glassfish']['asadmin']['timeout'] + 5
      user new_resource.system_user unless node['os'] == 'windows'
      group new_resource.system_group unless node['os'] == 'windows'
      command asadmin_command(args.join(' '))
    end
  end

  if !cache_present || !may_need_create
    sets = {'description' => new_resource.description}
    new_resource.properties.each_pair do |key, value|
      sets["property.#{key}"] = value
    end

    parameters.each do |key, mapping|
      sets[mapping] = new_resource.send(key)
    end

    sets.each_pair do |key, value|
      variable = "resources.jdbc-connection-pool.#{new_resource.name}.#{key}"
      glassfish_property "#{variable}=#{value}" do
        domain_name new_resource.domain_name
        admin_port new_resource.admin_port
        username new_resource.username
        password_file new_resource.password_file
        secure new_resource.secure
        key variable
        value value.to_s
      end
    end
  end
end

action :delete do
  cache_present = RealityForge::GlassFish.is_property_cache_present?(node, new_resource.domain_name)
  may_need_delete =
    cache_present ?
      RealityForge::GlassFish.any_cached_property_start_with?(node, new_resource.domain_name, "resources.jdbc-connection-pool.#{new_resource.name}.") :
      true

  if may_need_delete
    args = []
    args << 'delete-jdbc-connection-pool'
    args << '--cascade=true'
    args << new_resource.name

    execute "asadmin_delete_jdbc_connection_pool #{new_resource.name}" do
      unless cache_present
        only_if "#{asadmin_command('list-jdbc-connection-pools')} | grep -F -x -- '#{new_resource.name}'", :timeout => node['glassfish']['asadmin']['timeout'] + 5
      end
      timeout node['glassfish']['asadmin']['timeout'] + 5
      user new_resource.system_user unless node['os'] == 'windows'
      group new_resource.system_group unless node['os'] == 'windows'
      command asadmin_command(args.join(' '))
    end
  end
end
