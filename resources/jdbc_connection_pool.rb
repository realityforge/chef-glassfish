#
# Copyright:: Peter Donald
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

JdbcAttribute = Struct.new('JdbcAttribute', :key, :type, :arg, :default_value)

ATTRIBUTES = [] # rubocop:disable Style/MutableConstant

private

def self.str(key, arg, default_value = '')
  ATTRIBUTES << JdbcAttribute.new(key, :string, arg, default_value)
end

def self.num(key, arg, default_value = 0)
  ATTRIBUTES << JdbcAttribute.new(key, :numeric, arg, default_value)
end

def self.bool(key, arg, default_value = true)
  ATTRIBUTES << JdbcAttribute.new(key, :boolean, arg, default_value)
end

str(:datasourceclassname, 'datasource-classname')
str(:initsql, 'init-sql')
str(:sqltracelisteners, 'sql-trace-listeners')
str(:driverclassname, 'driver-classname')
str(:validationclassname, 'validation-classname')
str(:validationtable, 'validation-table-name')

num(:steadypoolsize, 'steady-pool-size', 8)
num(:maxpoolsize, 'max-pool-size', 32)
num(:maxwait, 'max-wait-time-in-millis', 60000)
num(:poolresize, 'pool-resize-quantity', 2)
num(:idletimeout, 'idle-timeout-in-seconds', 300)
num(:validateatmostonceperiod, 'validate-atmost-once-period-in-seconds')
num(:leaktimeout, 'connection-leak-timeout-in-seconds')
num(:statementleaktimeout, 'statement-leak-timeout-in-seconds')
num(:creationretryattempts, 'connection-creation-retry-attempts')
num(:creationretryinterval, 'connection-creation-retry-interval-in-seconds', 10)
num(:statementtimeout, 'statement-timeout-in-seconds', -1)
num(:maxconnectionusagecount, 'max-connection-usage-count')
num(:statementcachesize, 'statement-cache-size')

bool(:isisolationguaranteed, 'is-isolation-level-guaranteed')
bool(:isconnectvalidatereq, 'is-connection-validation-required')
bool(:failconnection, 'fail-all-connections', false)
bool(:allownoncomponentcallers, 'allow-non-component-callers', false)
bool(:nontransactionalconnections, 'non-transactional-connections', false)
bool(:statmentleakreclaim, 'statement-leak-reclaim', false)
bool(:leakreclaim, 'connection-leak-reclaim', false)
bool(:lazyconnectionenlistment, 'lazy-connection-enlistment', false)
bool(:lazyconnectionassociation, 'lazy-connection-association', false)
bool(:associatewiththread, 'associate-with-thread', false)
bool(:matchconnections, 'match-connections', false)
bool(:ping, 'ping')
bool(:pooling, 'pooling')
bool(:wrapjdbcobjects, 'wrap-jdbc-objects')

public

actions :create, :delete

attribute :pool_name, kind_of: String, name_attribute: true

ATTRIBUTES.each do |attr|
  if attr.type == :string
    attribute attr.key, kind_of: String, default: attr.default_value
  elsif attr.type == :numeric
    attribute attr.key, kind_of: [Integer, String], regex: /^-?[0-9]+$/, default: attr.default_value
  else
    attribute attr.key, equal_to: [true, false, 'true', 'false'], default: attr.default_value
  end
end

attribute :description, kind_of: String, default: nil
attribute :properties, kind_of: Hash, default: {}
attribute :restype,
          equal_to: %w(java.sql.Driver javax.sql.DataSource javax.sql.XADataSource javax.sql.ConnectionPoolDataSource),
          default: nil
attribute :isolationlevel, equal_to: %w(read-uncommitted read-committed repeatable-read serializable)
attribute :validationmethod, equal_to: %w(auto-commit meta-data table custom-validation)

# <> @attribute domain_name The name of the domain.
attribute :domain_name, kind_of: String, required: true
# <> @attribute terse Use terse output from the underlying asadmin.
attribute :terse, kind_of: [TrueClass, FalseClass], default: false
# <> @attribute echo If true, echo commands supplied to asadmin.
attribute :echo, kind_of: [TrueClass, FalseClass], default: true
# <> @attribute username The username to use when communicating with the domain.
attribute :username, kind_of: String, default: nil
# <> @attribute password_file The file in which the password must be stored assigned to appropriate key.
attribute :password_file, kind_of: String, default: nil
# <> @attribute secure If true use SSL when communicating with the domain for administration.
attribute :secure, kind_of: [TrueClass, FalseClass], default: false
# <> @attribute admin_port The port on which the web management console is bound.
attribute :admin_port, kind_of: Integer, default: 4848

# <> @attribute system_user The user that the domain executes as. Defaults to `node['glassfish']['user']` if unset.
attribute :system_user, kind_of: String, default: nil
# <> @attribute system_group The group that the domain executes as. Defaults to `node['glassfish']['group']` if unset.
attribute :system_group, kind_of: String, default: nil

default_action :create

def initialize(*args)
  super
  @system_user = node['glassfish']['user']
  @system_group = node['glassfish']['group']
end
