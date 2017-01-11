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

provides :glassfish_library, os: 'windows'

def type_flag
  "--type #{new_resource.library_type}"
end

def service_name
  "#{new_resource.domain_name}"
end

def domain_dir_arg
  "--domaindir #{node['glassfish']['domains_dir']}"
end



use_inline_resources

action :add do
  windows_service service_name do
    asadmin = Asadmin.asadmin_script(node)
    password_file = new_resource.password_file ? "--passwordfile=#{new_resource.password_file}" : ""

    #Stopping the service with the native command is not working for some reason...
    restart_command            "#{asadmin} restart-domain #{password_file} #{domain_dir_arg} #{new_resource.domain_name}"
    stop_command               "#{asadmin} stop-domain #{password_file} #{domain_dir_arg} #{new_resource.domain_name}"

    supports                   :restart => true, :reload => false, :status => true, :start => true, :stop => true
    timeout                    120

    action                     :nothing
  end

  cached_package_filename = "#{Chef::Config[:file_cache_path]}/#{new_resource.domain_name}_#{Digest::SHA1.hexdigest(new_resource.url)}/#{::File.basename(new_resource.url)}"
  check_command = "#{asadmin_command('list-libraries')} #{type_flag} | findstr /B /R /C:\"#{::File.basename(new_resource.url)}\""

  directory ::File.dirname(cached_package_filename) do
    not_if check_command
    owner new_resource.system_user
    group new_resource.system_group unless node.windows?
    mode '0770'
    recursive true
  end

  remote_file cached_package_filename do
    not_if check_command
    source new_resource.url
    owner new_resource.system_user
    group new_resource.system_group unless node.windows?
    mode '0640'
    action :create_if_missing
  end

  execute "asadmin_add-library #{new_resource.url}" do
    not_if check_command, :timeout => node['glassfish']['asadmin']['timeout'] + 5
    # execute should wait for asadmin to time out first, if it doesn't because of some problem, execute should time out eventually
    timeout node['glassfish']['asadmin']['timeout'] + 5

    args = []
    args << "--user #{new_resource.system_user}"
    args << 'add-library'
    args << type_flag
    args << '--upload' << new_resource.upload unless node['glassfish']['version'] == '4.1' || node['glassfish']['version'] == '4.1.151'
    args << cached_package_filename

    command asadmin_command(args.join(' '))

    if new_resource.requires_restart
      notifies :restart, "windows_service[#{service_name}]", :immediate
    end
  end
end

action :remove do
  args = []
  args << 'remove-library'
  args << type_flag
  args << ::File.basename(new_resource.url)

  execute "asadmin_remove-library #{new_resource.url}" do
    only_if "#{asadmin_command('list-libraries')} #{type_flag} | findstr /R /B /C:'#{::File.basename(new_resource.url)}'", :timeout => node['glassfish']['asadmin']['timeout'] + 5
    # execute should wait for asadmin to time out first, if it doesn't because of some problem, execute should time out eventually
    timeout node['glassfish']['asadmin']['timeout'] + 5
    user new_resource.system_user unless node.windows?
    group new_resource.system_group unless node.windows?
    command asadmin_command(command.join(' '))
  end
end
