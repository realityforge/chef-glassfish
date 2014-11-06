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

include Chef::Imqcmd

use_inline_resources

action :create do
  Chef::Log.info "Creating MQ Destination #{new_resource.destination_name}"

  bash "imqcmd_create_#{new_resource.queue ? 'queue' : 'topic'} #{new_resource.destination_name}" do
    not_if "#{imqcmd_command("query dst -t #{new_resource.queue ? 'q' : 't'} -n #{new_resource.destination_name}")} >/dev/null", :timeout => 150
    timeout 150
    user new_resource.system_user
    group new_resource.system_group
    code imqcmd_command("create dst -t #{new_resource.queue ? 'q' : 't'} -n #{new_resource.destination_name}")
  end

  processed_config = {}
  new_resource.config.each_pair do |k, v|
    if k.to_s == 'schema'
      processed_config['validateXMLSchemaEnabled'] = 'true'
      processed_config['XMLSchemaURIList'] = v
    else
      processed_config[k] = v
    end
  end

  bash "imqcmd_update_#{new_resource.queue ? 'queue' : 'topic'} #{new_resource.destination_name}" do
    only_if { processed_config.size > 0 }
    timeout 150
    user new_resource.system_user
    group new_resource.system_group
    code imqcmd_command("update dst -t #{new_resource.queue ? 'q' : 't'} -n #{new_resource.destination_name} #{processed_config.collect { |k, v| "-o #{k}=#{v}" }.join(' ')}")
  end
end


action :destroy do
  bash "imqcmd_create_#{new_resource.queue ? 'queue' : 'topic'} #{new_resource.destination_name}" do
    only_if "#{imqcmd_command("query dst -t #{new_resource.queue ? 'q' : 't'} -n #{new_resource.destination_name}")} >/dev/null", :timeout => 150
    timeout 150
    user new_resource.system_user
    group new_resource.system_group
    code imqcmd_command("destroy dst -t #{new_resource.queue ? 'q' : 't'} -n #{new_resource.destination_name}")
  end
end
