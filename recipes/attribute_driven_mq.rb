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

# Configures 0 or more GlassFish OpenMQ brokers using the openmq/instances attribute.
#
# The `attribute_driven_mq` recipe interprets attributes on the node and defines the resources described in the attributes.

def gf_priority(value)
  value.is_a?(Hash) && value['priority'] ? value['priority'] : 100
end

def gf_sort(hash)
  Hash[hash.sort_by { |key, value| "#{format('%04d', gf_priority(value))}#{key}" }]
end

include_recipe 'glassfish::default'

node['openmq']['extra_libraries'].each_value do |extra_library|
  library_location = "#{node['glassfish']['install_dir']}/mq/lib/ext/#{File.basename(extra_library)}"
  remote_file library_location do
    source extra_library
    unless node.windows?
      mode '0640'
      owner node['glassfish']['user']
      group node['glassfish']['group']
    end
    action :create_if_missing
  end
end

gf_sort(node['openmq']['instances']).each_pair do |instance_key, definition|
  RealityForge::GlassFish.set_current_broker_instance(node, instance_key)
  if definition['recipes'] && definition['recipes']['before']
    gf_sort(definition['recipes']['before']).each_pair do |recipe, config|
      Chef::Log.info "Including broker 'before' recipe '#{recipe}' Priority: #{gf_priority(config)}"
      include_recipe recipe
    end
  end
  RealityForge::GlassFish.set_current_broker_instance(node, nil)
end

node['openmq']['instances'].each_pair do |instance_key, definition|
  instance_key = instance_key.to_s
  RealityForge::GlassFish.set_current_broker_instance(node, instance_key)

  Chef::Log.info "Defining GlassFish #{instance_key} OpenMQ Server"

  requires_authbind = false

  requires_authbind ||= (definition['port'] && definition['port'] < 1024)
  requires_authbind ||= (definition['admin_port'] && definition['admin_port'] < 1024)
  requires_authbind ||= (definition['jms_port'] && definition['jms_port'] < 1024)
  requires_authbind ||= (definition['jmx_port'] && definition['jmx_port'] < 1024)
  requires_authbind ||= (definition['rmi_port'] && definition['rmi_port'] < 1024)
  requires_authbind ||= (definition['stomp_port'] && definition['stomp_port'] < 1024)

  include_recipe 'authbind' if requires_authbind

  include_recipe 'runit::default' if definition['init_style'] == 'runit'

  glassfish_mq instance_key do
    max_memory definition['max_memory'] if definition['max_memory']
    max_stack_size definition['max_stack_size'] if definition['max_stack_size']
    port definition['port'] if definition['port']
    admin_port definition['admin_port'] if definition['admin_port']
    jms_port definition['jms_port'] if definition['jms_port']
    jmx_port definition['jmx']['port'] if definition['jmx'] && definition['jmx']['port']
    rmi_port definition['jmx']['rmi_port'] if definition['jmx'] && definition['jmx']['rmi_port']
    jmx_admins definition['jmx']['admins'].to_hash if definition['jmx'] && definition['jmx']['admins']
    jmx_monitors definition['jmx']['monitors'].to_hash if definition['jmx'] && definition['jmx']['monitors']
    stomp_port definition['stomp_port'] if definition['stomp_port']
    admin_user definition['admin_user'] if definition['admin_user']
    config definition['config'] if definition['config']
    init_style definition['init_style'] if definition['init_style']
    logging_properties definition['logging_properties'] if definition['logging_properties']
    users definition['users'].to_hash
    access_control_rules definition['access_control_rules'].to_hash
    queues definition['destinations']['queues'].to_hash
    topics definition['destinations']['topics'].to_hash
  end
  RealityForge::GlassFish.set_current_broker_instance(node, nil)
end

gf_sort(node['openmq']['instances']).each_pair do |instance_key, definition|
  RealityForge::GlassFish.set_current_broker_instance(node, instance_key)
  if definition['recipes'] && definition['recipes']['after']
    gf_sort(definition['recipes']['after']).each_pair do |recipe, config|
      Chef::Log.info "Including broker 'after' recipe '#{recipe}' Priority: #{gf_priority(config)}"
      include_recipe recipe
    end
  end
  RealityForge::GlassFish.set_current_broker_instance(node, nil)
end
