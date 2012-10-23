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

actions :create, :delete

attribute :pool_name, :kind_of => String, :name_attribute => true

attribute :description, :kind_of => String, :default => nil
attribute :raname, :kind_of => String, :required => true
attribute :connectiondefinition, :kind_of => String, :required => true

attribute :description, :kind_of => String, :default => nil

NUMERIC_ATTRIBUTES = [:steadypoolsize,
                      :maxpoolsize,
                      :maxwait,
                      :poolresize,
                      :idletimeout,
                      :leaktimeout,
                      :validateatmostonceperiod,
                      :maxconnectionusagecount,
                      :creationretryattempts,
                      :creationretryinterval]

NUMERIC_ATTRIBUTES.each do |key|
  attribute key, :kind_of => [Fixnum, String], :regex => /^[0-9]+$/, :default => nil
end

BOOLEAN_ATTRIBUTES = [:isconnectvalidatereq,
                      :failconnection,
                      :leakreclaim,
                      :lazyconnectionenlistment,
                      :lazyconnectionassociation,
                      :associatewiththread,
                      :matchconnections,
                      :ping,
                      :pooling]

BOOLEAN_ATTRIBUTES.each do |key|
  attribute key, :equal_to => [true, false, 'true', 'false'], :default => nil
end

attribute :properties, :kind_of => Hash, :default => {}

attribute :transactionsupport, :equal_to => [' XATransaction', 'LocalTransaction', 'NoTransaction']

attribute :domain_name, :kind_of => String, :required => true
attribute :terse, :kind_of => [TrueClass, FalseClass], :default => false
attribute :echo, :kind_of => [TrueClass, FalseClass], :default => true
attribute :username, :kind_of => String, :default => nil
attribute :password_file, :kind_of => String, :default => nil
attribute :secure, :kind_of => [TrueClass, FalseClass], :default => false
attribute :admin_port, :kind_of => Integer, :default => 4848

default_action :create
