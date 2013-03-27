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

=begin
#<
The `attribute_driven_mq` recipe interprets attributes on the node and defines the resources described in the attributes.
#>
=end

include_recipe "glassfish::default"

node['openmq']['extra_libraries'].values.each do |extra_library|
  library_location = "#{node['glassfish']['base_dir']}/mq/lib/ext/#{File.basename(extra_library)}"
  remote_file library_location do
    source extra_library
    mode "0640"
    owner node['glassfish']['user']
    group node['glassfish']['group']
    action :create_if_missing
  end
end

node['openmq']['instances'].each_pair do |instance, definition|
  instance = instance.to_s

  Chef::Log.info "Defining GlassFish #{instance} OpenMQ Server"

  requires_authbind = false

  requires_authbind ||= (definition['port'] && definition['port'] < 1024)
  requires_authbind ||= (definition['admin_port'] && definition['admin_port'] < 1024)
  requires_authbind ||= (definition['jms_port'] && definition['jms_port'] < 1024)
  requires_authbind ||= (definition['jmx_port'] && definition['jmx_port'] < 1024)
  requires_authbind ||= (definition['stomp_port'] && definition['stomp_port'] < 1024)

  if requires_authbind
    include_recipe 'authbind'
  end

  glassfish_mq instance do
    max_memory definition['max_memory'] if definition['max_memory']
    max_stack_size definition['max_stack_size'] if definition['max_stack_size']
    port definition['port'] if definition['port']
    admin_port definition['admin_port'] if definition['admin_port']
    jms_port definition['jms_port'] if definition['jms_port']
    jmx_port definition['jmx']['port'] if definition['jmx'] && definition['jmx']['port']
    jmx_admins definition['jmx']['admins'].to_hash if definition['jmx'] && definition['jmx']['admins']
    jmx_monitors definition['jmx']['monitors'].to_hash if definition['jmx'] && definition['jmx']['monitors']
    stomp_port definition['stomp_port'] if definition['stomp_port']
    admin_user definition['admin_user'] if definition['admin_user']
    config definition['config'] if definition['config']
    logging_properties definition['logging_properties'] if definition['logging_properties']
    users node['openmq']['users'].to_hash
    access_control_rules node['openmq']['access_control_rules'].to_hash
    queues node['openmq']['destinations']['queues'].to_hash
    topics node['openmq']['destinations']['topics'].to_hash
  end
end
