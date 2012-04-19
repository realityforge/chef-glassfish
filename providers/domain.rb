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

def domain_dir_arg
  "--domaindir #{node[:glassfish][:domains_dir]}"
end

def replace_in_domain_file(key, value)
  "sed -i 's/#{key}/#{value}/g' #{node[:glassfish][:domains_dir]}/#{new_resource.domain_name}/config/domain.xml 2> /dev/null > /dev/null"
end

action :create do
  requires_authbind = new_resource.port < 1024 || new_resource.admin_port < 1024

  template "/etc/init.d/glassfish-#{new_resource.domain_name}" do
    source "glassfish-init.d-script.erb"
    mode "0755"
    cookbook 'glassfish'
    variables(:domain_name => new_resource.domain_name, :authbind => requires_authbind, :listen_ports => [new_resource.admin_port, new_resource.port])
  end

  if new_resource.port < 1024
    authbind_port "AuthBind GlassFish Port #{new_resource.port}" do
      port new_resource.port
      user node[:glassfish][:user]
    end
  end

  if new_resource.admin_port < 1024
    authbind_port "AuthBind GlassFish Port #{new_resource.admin_port}" do
      port new_resource.admin_port
      user node[:glassfish][:user]
    end
  end

  bash "create domain #{new_resource.domain_name}" do
    not_if "#{asadmin_command('list-domains')} #{domain_dir_arg}| grep -- '#{new_resource.domain_name} '"

    args = []
    args << "--instanceport #{new_resource.port}"
    args << "--adminport #{new_resource.admin_port}"
    args << "--nopassword=false" if new_resource.username
    args <<  domain_dir_arg
    command_string = []
    command_string << (requires_authbind ? "authbind --deep " : "") + asadmin_command("create-domain #{args.join(' ')} #{new_resource.domain_name}", false)
    command_string << replace_in_domain_file("%%%CPU_NODE_COUNT%%%", node[:cpu].size - 2)
    command_string << replace_in_domain_file("%%%MAX_PERM_SIZE%%%", new_resource.max_perm_size)
    command_string << replace_in_domain_file("%%%MAX_STACK_SIZE%%%", new_resource.max_stack_size)
    command_string << replace_in_domain_file("%%%MAX_MEM_SIZE%%%", new_resource.max_memory)
    command_string << asadmin_command("verify-domain-xml #{new_resource.domain_name}", false)

    user node[:glassfish][:user]
    group node[:glassfish][:group]
    code command_string.join("\n")
  end

  file "#{node[:glassfish][:domains_dir]}/#{new_resource.domain_name}/docroot/index.html" do
    action :delete
  end

  if new_resource.extra_libraries
    new_resource.extra_libraries.each do |extra_library|
      library_location = "#{node[:glassfish][:domains_dir]}/#{new_resource.domain_name}/lib/ext/#{::File.basename(extra_library)}"
      remote_file library_location do
        source extra_library
        mode "0640"
        owner node[:glassfish][:user]
        group node[:glassfish][:group]
        not_if { ::File.exists?(library_location) }
      end
    end
  end

  service "glassfish-#{new_resource.domain_name}" do
    supports :start => true, :restart => true, :stop => true
    action [:enable, :start]
  end

  glassfish_property "server.ejb-container.property.disable-nonportable-jndi-names=true" do
    domain_name new_resource.domain_name
  end
end

action :destroy do
  execute "destroy domain" do
    only_if "#{asadmin_command('list-domains')} #{domain_dir_arg} | grep -- '#{new_resource.domain_name} '"
    command_string = []

    command_string << "#{asadmin_command("stop-domain #{domain_dir_arg} #{new_resource.domain_name}", false)} 2> /dev/null > /dev/null"
    command_string << asadmin_command("delete-domain #{domain_dir_arg} #{new_resource.domain_name}", false)

    command command_string.join("\n")
  end
end
