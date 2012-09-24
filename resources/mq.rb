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

actions :create, :destroy

attribute :max_memory, :kind_of => Integer, :default => 512
attribute :max_stack_size, :kind_of => Integer, :default => 128
attribute :instance, :kind_of => String, :name_attribute => true
attribute :users, :kind_of => Hash, :default => {}
attribute :access_control_rules, :kind_of => Hash, :default => {}
attribute :logging_properties,
          :kind_of => Hash,
          :default =>
            {
              "handlers" => "java.util.logging.ConsoleHandler",
              ".level" => "INFO",
              "java.util.logging.ConsoleHandler.level" => "INFO",
            }
attribute :config, :kind_of => Hash, :default => {}
attribute :queues, :kind_of => Hash, :default => {}
attribute :topics, :kind_of => Hash, :default => {}
attribute :jmx_admins, :kind_of => Hash, :default => {}
attribute :jmx_monitors, :kind_of => Hash, :default => {}
attribute :admin_user, :kind_of => String, :default => 'imqadmin'

attribute :port, :kind_of => Integer, :default => 7676
attribute :admin_port, :kind_of => Integer, :default => 7677
attribute :jms_port, :kind_of => Integer, :default => 7678
attribute :jmx_port, :kind_of => Integer, :default => nil
attribute :stomp_port, :kind_of => Integer, :default => nil

default_action :create
