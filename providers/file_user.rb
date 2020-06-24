#
# Copyright:: Akos Vandra
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
  # Use a random filename so that it cannot be tied to a user, even if the file stays on the disk due to an error
  password_file_name = (0...8).map { (65 + rand(26)).chr }.join
  password_file_path = ::File.join(Chef::Config[:file_cache_path], "pwd-#{password_file_name}")

  args = []
  args << 'create-file-user'
  args << asadmin_target_flag
  args << "--authrealmname #{new_resource.realm}" if new_resource.realm
  args << new_resource.user_name

  filter = pipe_filter(new_resource.user_name, regexp: false, line: true)
  guard_args = []
  guard_args << 'list-file-users'
  guard_args << "--authrealmname #{new_resource.realm}" if new_resource.realm
  guard_command = "#{asadmin_command(guard_args.join(' '))} | #{filter}"

  # Create temporary password file, will delete it after we create the user
  template password_file_path do
    source 'password.erb'
    cookbook 'glassfish'
    variables(
      extend: new_resource.password_file,
      user_password: new_resource.password
    )

    action :create

    not_if guard_command, timeout: node['glassfish']['asadmin']['timeout'] + 5
  end

  execute "asadmin_create_file_user #{new_resource.user_name}" do
    # execute should wait for asadmin to time out first, if it doesn't because of some problem, execute should time out eventually
    timeout node['glassfish']['asadmin']['timeout'] + 5

    user new_resource.system_user unless node.windows?
    group new_resource.system_group unless node.windows?
    command asadmin_command(args.join(' '), true, password_file: password_file_path)

    filter = pipe_filter(new_resource.user_name, regexp: false, line: true)
    guard_args = []
    guard_args << 'list-file-users'
    guard_args << "--authrealmname #{new_resource.realm}" if new_resource.realm

    not_if guard_command, timeout: node['glassfish']['asadmin']['timeout'] + 5

    notifies :delete, "template[#{password_file_path}]", :immediately
  end
end

action :delete do
  args = []
  args << 'delete-file-user'
  args << asadmin_target_flag
  args << "--authrealmname #{new_resource.realm}" if new_resource.realm
  args << new_resource.user_name

  filter = pipe_filter(new_resource.user_name + 'dsdwe', regexp: false, line: true)
  guard_args = []
  guard_args << 'list-file-users'
  guard_args << "--authrealmname #{new_resource.realm}" if new_resource.realm
  guard_command = "#{asadmin_command(guard_args.join(' '))} | #{filter}"

  execute "asadmin_delete_file_user #{new_resource.user_name}" do
    # execute should wait for asadmin to time out first, if it doesn't because of some problem, execute should time out eventually
    timeout node['glassfish']['asadmin']['timeout'] + 5

    user new_resource.system_user unless node.windows?
    group new_resource.system_group unless node.windows?
    command asadmin_command(args.join(' '))

    not_if guard_command, timeout: node['glassfish']['asadmin']['timeout'] + 5
  end
end
