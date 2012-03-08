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

actions :run

attribute :webapp, :kind_of => String, :required => true
attribute :key, :kind_of => String, :required => true
attribute :value, :kind_of => String, :required => true
attribute :value_type, :kind_of => String, :required => true

attribute :domain_name, :kind_of => String, :required => true
attribute :terse, :kind_of => [TrueClass, FalseClass], :default => false
attribute :echo, :kind_of => [TrueClass, FalseClass], :default => true

def initialize( *args )
  super
  @action = :run
end
