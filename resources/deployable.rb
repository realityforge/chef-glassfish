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

actions :deploy, :undeploy

attribute :deployable_key, :kind_of => String, :name_attribute => true
attribute :version, :kind_of => String, :required => true
attribute :url, :kind_of => String, :required => true
attribute :enabled, :kind_of => [TrueClass, FalseClass], :default => true
attribute :type, :kind_of => Symbol, :default => nil
attribute :upload, :kind_of => [TrueClass, FalseClass], :default => true
attribute :force, :kind_of => [TrueClass, FalseClass], :default => true
attribute :context_root, :kind_of => String, :default => nil
attribute :virtual_servers, :kind_of => Array, :default => ['server']

attribute :domain_name, :kind_of => String, :required => true
attribute :terse, :kind_of => [TrueClass, FalseClass], :default => false
attribute :echo, :kind_of => [TrueClass, FalseClass], :default => true

def initialize( *args )
  super
  @action = :deploy
end
