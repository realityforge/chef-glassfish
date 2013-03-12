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

def type_flag
  "--type #{new_resource.library_type}"
end

use_inline_resources

action :add do
  cached_package_filename = "#{Chef::Config[:file_cache_path]}/#{Digest::SHA1.hexdigest(new_resource.url)}/#{::File.basename(new_resource.url)}"
  check_command = "#{asadmin_command('list-libraries')} #{type_flag} | grep -x -- '#{::File.basename(new_resource.url)}'"

  directory ::File.dirname(cached_package_filename) do
    not_if check_command
    owner node['glassfish']['user']
    group node['glassfish']['group']
    mode '0700'
    recursive true
  end

  remote_file cached_package_filename do
    not_if check_command
    source new_resource.url
    owner node['glassfish']['user']
    group node['glassfish']['group']
    mode '0600'
    action :create_if_missing
  end

  command = []
  command << "add-library"
  command << type_flag
  command << "--upload" << new_resource.upload
  command << cached_package_filename

  bash "asadmin_add-library #{new_resource.url}" do
    not_if check_command
    user node['glassfish']['user']
    group node['glassfish']['group']
    code asadmin_command(command.join(' '))
  end
end

action :remove do
  command = []
  command << "remove-library"
  command << type_flag
  command << ::File.basename(new_resource.url)

  bash "asadmin_remove-library #{new_resource.url}" do
    only_if "#{asadmin_command('list-libraries')} #{type_flag} | grep -x -- '#{::File.basename(new_resource.url)}'"
    user node['glassfish']['user']
    group node['glassfish']['group']
    code asadmin_command(command.join(' '))
  end
end
