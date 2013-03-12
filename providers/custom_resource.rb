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
  command = []
  command << "create-custom-resource"
  command << "--restype" << new_resource.restype
  factoryclass = new_resource.factoryclass || "org.glassfish.resources.custom.factory.PrimitivesAndStringFactory"
  command << "--factoryclass" << factoryclass
  command << "--enabled=#{new_resource.enabled}" if new_resource.enabled
  command << "--description" << "'#{new_resource.description}'" if new_resource.description
  properties = new_resource.properties.dup
  properties['value'] = new_resource.value if new_resource.value
  command << "--property" << encode_parameters(properties) unless properties.empty?
  command << asadmin_target_flag
  command << new_resource.jndi_name

  bash "asadmin_create-custom-resource #{new_resource.jndi_name} => #{new_resource.value}" do
    not_if "#{asadmin_command('list-custom-resources')} #{new_resource.target} | grep -x -- '#{new_resource.jndi_name}'"
    user node['glassfish']['user']
    group node['glassfish']['group']
    code asadmin_command(command.join(' '))
  end

  sets = {'factory-class' => factoryclass, 'res-type' => new_resource.restype}
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

action :delete do
  command = []
  command << "delete-custom-resource"
  command << asadmin_target_flag
  command << new_resource.jndi_name

  bash "asadmin_delete-custom-resource #{new_resource.jndi_name}" do
    only_if "#{asadmin_command('list-custom-resources')} #{new_resource.target} | grep -x -- '#{new_resource.jndi_name}'"
    user node['glassfish']['user']
    group node['glassfish']['group']
    code asadmin_command(command.join(' '))
  end
end
