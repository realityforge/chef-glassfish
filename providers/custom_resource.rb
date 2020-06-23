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
                      !RealityForge::GlassFish.any_cached_property_start_with?(node, new_resource.domain_name, "resources.custom-resource.#{new_resource.jndi_name}.")
                    else
                      true
                    end

  factoryclass = new_resource.factoryclass || 'org.glassfish.resources.custom.factory.PrimitivesAndStringFactory'
  properties = new_resource.properties.dup
  properties['value'] = new_resource.value unless new_resource.value.nil?

  if may_need_create
    args = []
    args << 'create-custom-resource'
    args << '--restype' << new_resource.restype
    args << '--factoryclass' << factoryclass
    args << "--enabled=#{new_resource.enabled}" if new_resource.enabled
    args << '--description' << "\"#{new_resource.description}\"" if new_resource.description
    args << '--property' << encode_parameters(properties) unless properties.empty?
    args << asadmin_target_flag
    args << new_resource.jndi_name

    execute "asadmin_create-custom-resource #{new_resource.jndi_name} => #{new_resource.value}" do
      timeout node['glassfish']['asadmin']['timeout'] + 5
      user new_resource.system_user unless node.windows?
      group new_resource.system_group unless node.windows?
      command asadmin_command(args.join(' '))
      unless cache_present
        filter = pipe_filter(new_resource.jndi_name, regexp: false, line: true)
        not_if "#{asadmin_command('list-custom-resources')} #{new_resource.target} | #{filter}", timeout: node['glassfish']['asadmin']['timeout'] + 5
      end
    end
  end
  if !cache_present || !may_need_create
    sets = { 'factory-class' => factoryclass, 'res-type' => new_resource.restype }
    properties.each_pair do |key, value|
      sets["property.#{key}"] = value
    end
    sets['enabled'] = !!new_resource.enabled
    sets.each_pair do |key, value|
      variable = "resources.custom-resource.#{new_resource.jndi_name}.#{key}"
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
  cache_present = RealityForge::GlassFish.property_cache_present?(node, new_resource.domain_name)
  may_need_delete = if cache_present
                      RealityForge::GlassFish.any_cached_property_start_with?(node, new_resource.domain_name, "resources.custom-resource.#{new_resource.jndi_name}.")
                    else
                      true
                    end

  if may_need_delete
    args = []
    args << 'delete-custom-resource'
    args << asadmin_target_flag
    args << new_resource.jndi_name

    execute "asadmin_delete-custom-resource #{new_resource.jndi_name}" do
      timeout node['glassfish']['asadmin']['timeout'] + 5
      user new_resource.system_user unless node.windows?
      group new_resource.system_group unless node.windows?
      command asadmin_command(args.join(' '))
      unless cache_present
        filter = pipe_filter(new_resource.name, regexp: false, line: true)
        only_if "#{asadmin_command('list-custom-resources')} #{new_resource.target} | #{filter}", timeout: node['glassfish']['asadmin']['timeout'] + 5
      end
    end
  end
end
