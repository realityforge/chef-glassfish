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
attribute :port, :kind_of => Integer, :default => 7676
attribute :name, :kind_of => String, :name_attribute => true
attribute :var_home, :kind_of => String, :default => nil

def initialize( *args )
  super
  @action = :create
end
