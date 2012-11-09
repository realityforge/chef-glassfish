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

attribute :min_memory, :kind_of => Integer, :default => 512
attribute :max_memory, :kind_of => Integer, :default => 512
attribute :max_perm_size, :kind_of => Integer, :default => 96
attribute :max_stack_size, :kind_of => Integer, :default => 128
attribute :port, :kind_of => Integer, :default => 8080
attribute :admin_port, :kind_of => Integer, :default => 4848
attribute :extra_jvm_options, :kind_of => Array, :default => []
attribute :env_variables, :kind_of => Hash, :default => {}

attribute :domain_name, :kind_of => String, :name_attribute => true
attribute :terse, :kind_of => [TrueClass, FalseClass], :default => false
attribute :echo, :kind_of => [TrueClass, FalseClass], :default => true
attribute :username, :kind_of => String, :default => nil
attribute :password, :kind_of => String, :default => nil
attribute :password_file, :kind_of => String, :default => nil
attribute :secure, :kind_of => [TrueClass, FalseClass], :default => false
attribute :logging_properties, :kind_of => Hash, :default => {}
attribute :realm_types, :kind_of => Hash, :default => {}

default_action :create
