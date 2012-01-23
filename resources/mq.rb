#
# Cookbook Name:: glassfish
# Recipe:: default
#
# Copyright 2011, Peter Donald
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
attribute :var_home, :kind_of => String, :default => "/var/omq"
attribute :users, :kind_of => Hash, :default => {}
attribute :access_control_rules, :kind_of => Hash, :default => {}
attribute :config, :kind_of => Hash, :default => {}
attribute :admin_group, :kind_of => String, :default => 'omq_admins'
attribute :monitor_group, :kind_of => String, :default => 'omq_monitors'
attribute :bridge_user, :kind_of => String, :default => 'bridge'

attribute :port, :kind_of => Integer, :default => 7676
attribute :admin_port, :kind_of => Integer, :default => 7677
attribute :jms_port, :kind_of => Integer, :default => 7678
attribute :jmx_port, :kind_of => Integer, :default => nil
attribute :stomp_port, :kind_of => Integer, :default => nil

def initialize( *args )
  super
  @action = :create
end
