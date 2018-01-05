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

def service_name
  "#{new_resource.domain_name}"
end

action :set do
  service service_name do
    supports :restart => true, :status => true
    action :nothing
  end

  output = `#{asadmin_command('list-jvm-options', true, :terse => true, :echo => false)}`

  # Work around bugs in 3.1.2.2
  if node['glassfish']['version'] == '3.1.2.2'
    existing = output.gsub(' ', '+').split("\n")
    new_resource.options.each do |line|
      unless existing.include?(line)
        args = []
        args << 'create-jvm-options'
        args << asadmin_target_flag
        args << encode_options([line])

        execute "asadmin_create-jvm-option #{line}" do
          # execute should wait for asadmin to time out first, if it doesn't because of some problem, execute should time out eventually
          timeout node['glassfish']['asadmin']['timeout'] + 5

          user new_resource.system_user unless node.windows?
          group new_resource.system_group unless node.windows?
          command asadmin_command(args.join(' '))

          notifies :restart, "service[glassfish-#{new_resource.domain_name}]", :delayed
        end
      end
    end
    existing.each do |line|
      unless new_resource.options.include?(line)
        args = []
        args << 'delete-jvm-options'
        args << asadmin_target_flag
        args << encode_options([line])

        execute "asadmin_delete-jvm-option #{line}" do
          # execute should wait for asadmin to time out first, if it doesn't because of some problem, execute should time out eventually
          timeout node['glassfish']['asadmin']['timeout'] + 5

          user new_resource.system_user unless node.windows?
          group new_resource.system_group unless node.windows?
          command asadmin_command(args.join(' '))

          notifies :restart, "service[glassfish-#{new_resource.domain_name}]", :delayed
        end
      end
    end
  else
    existing = output.split("\n")

    existing_option_string = encode_options(existing)
    new_option_string = encode_options(new_resource.options)

    if existing_option_string != new_option_string
      execute "asadmin_delete-jvm-options #{new_resource.name}" do
        delete_command = []
        delete_command << 'delete-jvm-options'
        delete_command << existing_option_string
        delete_command << asadmin_target_flag

        # execute should wait for asadmin to time out first, if it doesn't because of some problem, execute should time out eventually
        timeout node['glassfish']['asadmin']['timeout'] + 5

        user new_resource.system_user unless node.windows?
        group new_resource.system_group unless node.windows?
        command "#{asadmin_command(delete_command.join(' '))}"

        notifies :run, "execute[asadmin_create-jvm-options #{new_resource.name}]", :immediate
      end

      execute "asadmin_create-jvm-options #{new_resource.name}" do
        create_command = []
        create_command << 'create-jvm-options'
        create_command << new_option_string
        create_command << asadmin_target_flag

        # execute should wait for asadmin to time out first, if it doesn't because of some problem, execute should time out eventually
        timeout node['glassfish']['asadmin']['timeout'] + 5

        user new_resource.system_user unless node.windows?
        group new_resource.system_group unless node.windows?
        command "#{asadmin_command(create_command.join(' '))}"

        action :nothing
        notifies :restart, "service[#{service_name}]", :immediate
      end
    end
  end
end
