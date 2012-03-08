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

include_recipe "glassfish::default"

included_authbind = false

node[:glassfish][:domain_definitions].each_pair do |domain_key, definition|
  domain_key = domain_key.to_s

  Chef::Log.info "Defining GlassFish Domain #{domain_key}"

  directory "#{node[:glassfish][:domains_dir]}" do
    owner node[:glassfish][:user]
    group node[:glassfish][:group]
    mode "0700"
  end

  if definition[:config][:password]
    template "#{node[:glassfish][:domains_dir]}/#{domain_key}_admin_passwd" do
      source "password.erb"
      owner node[:glassfish][:user]
      group node[:glassfish][:group]
      mode "0600"
      variables :domain_name => domain_key
    end
  end

  requires_authbind = (definition[:config][:port] && definition[:config][:port] < 1024) || (definition[:config][:admin_port] && definition[:config][:admin_port] < 1024)

  if requires_authbind && !included_authbind
    included_authbind = true
    include_recipe "authbind"
  end

  glassfish_domain domain_key do
    max_memory definition[:config][:max_memory] if definition[:config][:max_memory]
    max_perm_size definition[:config][:max_perm_size] if definition[:config][:max_perm_size]
    max_stack_size definition[:config][:max_stack_size] if definition[:config][:max_stack_size]
    port definition[:config][:port] if definition[:config][:port]
    admin_port definition[:config][:admin_port] if definition[:config][:admin_port]
    username definition[:config][:username] if definition[:config][:username]
    password definition[:config][:password] if definition[:config][:password]
  end

  if definition[:extra_libraries]
    definition[:extra_libraries].each do |extra_library|
      library_location = "#{node[:glassfish][:domains_dir]}/#{domain_key}/lib/ext/#{::File.basename(extra_library)}"
      remote_file library_location do
        source extra_library
        mode "0640"
        owner node[:glassfish][:user]
        group node[:glassfish][:group]
        not_if { ::File.exists?(library_location) }
        #notifies :restart, resources(:service => "glassfish-#{domain_key}")
      end
    end
  end

  if definition[:jvm_options]
    definition[:jvm_options].each do |jvm_option|
      glassfish_jvm_option jvm_option do
        domain_name domain_key
      end
    end
  end

  if definition[:sets]
    definition[:sets].each do |set|
      glassfish_property set do
        domain_name domain_key
      end
    end
  end

  if definition[:realms]
    definition[:realms].each_pair do |key, configuration|
      glassfish_auth_realm key.to_s do
        domain_name domain_key
        parameters configuration[:parameters]
      end
    end
  end

  if definition[:jdbc_connection_pools]
    definition[:jdbc_connection_pools].each_pair do |key, configuration|
      key = key.to_s
      glassfish_jdbc_connection_pool key do
        domain_name domain_key
        parameters configuration[:parameters]
      end
      if configuration[:resources]
        configuration[:resources].each_pair do |resource_name, resource_configuration|
          params = ["--connectionpoolid #{key}"]
          params += resource_configuration[:parameters] if resource_configuration[:parameters]
          glassfish_jdbc_resource resource_name.to_s do
            domain_name domain_key
            parameters params
          end
        end
      end
    end
  end

  if definition[:deployables]
    definition[:deployables].each_pair do |deployable_key, configuration|
      glassfish_deployable deployable_key.to_s do
        domain_name domain_key
        version configuration[:version]
        url configuration[:url]
        context_root configuration[:context_root] if configuration[:context_root]
      end
      if configuration[:web_env_entries]
        configuration[:web_env_entries].each_pair do |key, value|
          glassfish_web_env_entry "#{deployable_key} set #{key}" do
            domain_name domain_key
            webapp deployable_key
            key key
            value value
            value_type value.is_a?(String) ? "java.lang.String" : value.is_a?(Fixnum) ? "java.lang.Integer" : (raise "Unknown env type #{value.inspect}")
          end
        end
      end
    end
  end
end

node[:openmq][:extra_libraries].each do |extra_library|
  library_location = "#{node[:glassfish][:base_dir]}/mq/lib/ext/#{File.basename(extra_library)}"
  remote_file library_location do
    source extra_library
    mode "0640"
    owner node[:glassfish][:user]
    group node[:glassfish][:group]
    not_if { ::File.exists?(library_location) }
  end
end

node[:openmq][:instances].each_pair do |instance, definition|
  instance = instance.to_s

  Chef::Log.info "Defining GlassFish #{instance} OpenMQ Server"

  directory "/var/omq" do
    owner node[:glassfish][:user]
    group node[:glassfish][:group]
    mode "0700"
  end

  requires_authbind = false

  requires_authbind ||= (definition[:port] && definition[:port] < 1024)
  requires_authbind ||= (definition[:admin_port] && definition[:admin_port] < 1024)
  requires_authbind ||= (definition[:jms_port] && definition[:jms_port] < 1024)
  requires_authbind ||= (definition[:jmx_port] && definition[:jmx_port] < 1024)
  requires_authbind ||= (definition[:stomp_port] && definition[:stomp_port] < 1024)

  if requires_authbind && !included_authbind
    included_authbind = true
    include_recipe "authbind"
  end

  access_control_rules = {}
  search(:node, "openmq_access_control_rules:* AND chef_environment:#{node.chef_environment} AND NOT name:#{node.name}") do |n|
    access_control_rules.merge!(n["openmq"]["access_control_rules"].to_hash)
  end
  access_control_rules.merge!(node["openmq"]["access_control_rules"].to_hash)

  users = {}
  search(:node, "openmq_users:* AND chef_environment:#{node.chef_environment} AND NOT name:#{node.name}") do |n|
    users.merge!(n["openmq"]["users"].to_hash)
  end
  users.merge!(node["openmq"]["users"].to_hash)

  queues = {}
  search(:node, "openmq_destinations_queues:* AND chef_environment:#{node.chef_environment} AND NOT name:#{node.name}") do |n|
    queues.merge!(n["openmq"]["destinations"]["queues"].to_hash)
  end
  queues.merge!(node["openmq"]["destinations"]["queues"].to_hash)

  topics = {}
  search(:node, "openmq_destinations_topics:* AND chef_environment:#{node.chef_environment} AND NOT name:#{node.name}") do |n|
    topics.merge!(n["openmq"]["destinations"]["topics"].to_hash)
  end
  topics.merge!(node["openmq"]["destinations"]["topics"].to_hash)

  glassfish_mq instance do
    max_memory definition[:max_memory] if definition[:max_memory]
    max_stack_size definition[:max_stack_size] if definition[:max_stack_size]
    port definition[:port] if definition[:port]
    admin_port definition[:admin_port] if definition[:admin_port]
    jms_port definition[:jms_port] if definition[:jms_port]
    jmx_port definition[:jmx_port] if definition[:jmx_port]
    stomp_port definition[:stomp_port] if definition[:stomp_port]
    var_home definition[:var_home] if definition[:var_home]
    admin_user definition[:admin_user] if definition[:admin_user]
    config definition[:config] if definition[:config]
    users users
    access_control_rules access_control_rules
    queues queues
    topics topics
  end
end
