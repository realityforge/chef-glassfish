#
# Cookbook Name:: glassfish
# Recipe:: default
#
# Copyright 2011, Fire Information Systems Group
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

def replace_in_domain_file(key, value)
  "sed -i 's/#{key}/#{value}/g' #{node[:glassfish][:domains_dir]}/#{new_resource.domain_name}/config/domain.xml"
end

action :create do
  bash "create domain" do
    not_if "#{asadmin_command('list-domains')} | grep -- '#{new_resource.domain_name} '"

    args = []
    args << "--nopassword"
    args << "--instanceport #{new_resource.port}"
    args << "--adminport #{new_resource.admin_port}"
    command_string = []
    command_string << asadmin_command("create-domain #{args.join(' ')} #{new_resource.domain_name}", false)
    command_string << replace_in_domain_file("%%%CPU_NODE_COUNT%%%", node[:cpu].size - 2)
    command_string << replace_in_domain_file("%%%MAX_PERM_SIZE%%%", new_resource.max_perm_size)
    command_string << replace_in_domain_file("%%%MAX_STACK_SIZE%%%", new_resource.max_stack_size)
    command_string << replace_in_domain_file("%%%MAX_MEM_SIZE%%%", new_resource.max_memory)
    command_string << asadmin_command("verify-domain-xml #{new_resource.domain_name}", false)

    user node[:glassfish][:user]
    group node[:glassfish][:group]
    code command_string.join("\n")
  end

  template "/etc/init.d/glassfish-#{new_resource.domain_name}" do
    source "glassfish-init.d-script.erb"
    mode "0755"
    cookbook 'glassfish'
    variables(:domain_name => new_resource.domain_name)
  end

  ruby_block "block_until_operational-#{new_resource.domain_name}" do
    block do
      until IO.popen("netstat -lnt").entries.select { |entry|
        entry.split[3] =~ /:#{new_resource.port}$/
      }.size == 1
        Chef::Log.debug "service[glassfish-#{new_resource.domain_name}] not listening on port #{new_resource.port}"
        sleep 1
      end

      loop do
        url = URI.parse("http://127.0.0.1:#{new_resource.port}/")
        res = Chef::REST::RESTRequest.new(:GET, url, nil).call
        break if res.kind_of?(Net::HTTPSuccess) || res.kind_of?(Net::HTTPNotFound) || res.kind_of?(Net::HTTPUnauthorized)
        Chef::Log.debug "service[glassfish-#{new_resource.domain_name}] not responding acceptable to GET on #{url}"
        sleep 1
      end
    end
    action :nothing
  end

  service "glassfish-#{new_resource.domain_name}" do
    supports :start => true, :restart => true, :stop => true
    action [:enable, :start]
    notifies :create, resources(:ruby_block => "block_until_operational-#{new_resource.domain_name}"), :immediately
  end
end

action :destroy do
  execute "destroy domain" do
    only_if "#{asadmin_command('list-domains')} | grep -- '#{new_resource.domain_name} '"
    command_string = []

    command_string << "#{asadmin_command("stop-domain #{new_resource.domain_name}", false)} 2> /dev/null > /dev/null"
    command_string << asadmin_command("delete-domain #{new_resource.domain_name}", false)

    command command_string.join("\n")
  end
end
