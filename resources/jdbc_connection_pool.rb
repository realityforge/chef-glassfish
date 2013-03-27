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

STRING_ATTRIBUTES = [:datasourceclassname,
                     :initsql,
                     :sqltracelisteners,
                     :driverclassname,
                     :validationclassname,
                     :validationtable]
STRING_ATTRIBUTES.each do |key|
  attribute key, :kind_of => String, :default => nil
end

NUMERIC_ATTRIBUTES = [:steadypoolsize,
                      :maxpoolsize,
                      :maxwait,
                      :poolresize,
                      :idletimeout,
                      :validateatmostonceperiod,
                      :leaktimeout,
                      :statementleaktimeout,
                      :creationretryattempts,
                      :creationretryinterval,
                      :statementtimeout,
                      :maxconnectionusagecount,
                      :statementcachesize]

NUMERIC_ATTRIBUTES.each do |key|
  attribute key, :kind_of => [Fixnum, String], :regex => /^[0-9]+$/, :default => nil
end

BOOLEAN_ATTRIBUTES = [:isisolationguaranteed,
                      :isconnectvalidatereq,
                      :failconnection,
                      :allownoncomponentcallers,
                      :nontransactionalconnections,
                      :statmentleakreclaim,
                      :leakreclaim,
                      :lazyconnectionenlistment,
                      :lazyconnectionassociation,
                      :associatewiththread,
                      :matchconnections,
                      :ping,
                      :pooling,
                      :wrapjdbcobjects]

BOOLEAN_ATTRIBUTES.each do |key|
  attribute key, :equal_to => [true, false, 'true', 'false'], :default => nil
end

attribute :description, :kind_of => String, :default => nil
attribute :properties, :kind_of => Hash, :default => {}
attribute :restype,
          :equal_to => ['java.sql.Driver',
                        'javax.sql.DataSource',
                        'javax.sql.XADataSource',
                        'javax.sql.ConnectionPoolDataSource'],
          :default => nil
attribute :isolationlevel, :equal_to => ['read-uncommitted', 'read-committed', 'repeatable-read', 'serializable']
attribute :validationmethod, :equal_to => ['auto-commit', 'meta-data', 'table', 'custom-validation']

#<> @attribute domain_name The name of the domain.
attribute :domain_name, :kind_of => String, :required => true
#<> @attribute terse Use terse output from the underlying asadmin.
attribute :terse, :kind_of => [TrueClass, FalseClass], :default => false
#<> @attribute echo If true, echo commands supplied to asadmin.
attribute :echo, :kind_of => [TrueClass, FalseClass], :default => true
#<> @attribute username The username to use when communicating with the domain.
attribute :username, :kind_of => String, :default => nil
#<> @attribute password_file The file in which the password must be stored assigned to appropriate key.
attribute :password_file, :kind_of => String, :default => nil
#<> @attribute secure If true use SSL when communicating with the domain for administration.
attribute :secure, :kind_of => [TrueClass, FalseClass], :default => false
#<> @attribute admin_port The port on which the web management console is bound.
attribute :admin_port, :kind_of => Integer, :default => 4848

default_action :create
