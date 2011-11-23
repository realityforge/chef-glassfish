#
# Cookbook Name:: glassfish
# Recipe:: default
#
# Copyright 2011, Fire Information Systems Group
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

attribute :domain_name, :kind_of => String, :name_attribute => true, :required => true
attribute :tune_gc, :kind_of => [TrueClass, FalseClass], :default => true
attribute :max_memory, :kind_of => Integer, :default => 1548
attribute :max_perm_size, :kind_of => Integer, :default => 192
attribute :max_stack_size, :kind_of => Integer, :default => 128
attribute :max_stack_size, :kind_of => Integer, :default => 128
attribute :jvm_options, :kind_of => Array, :default => [
  '-Djava.awt.headless=true',
  '-Djavax.management.builder.initial=com.sun.enterprise.v3.admin.AppServerMBeanServerBuilder',
  '-XX:UnlockDiagnosticVMOptions',
  '-Djava.endorsed.dirs=${com.sun.aas.installRoot}/modules/endorsed${path.separator}${com.sun.aas.installRoot}/lib/endorsed',
  '-Djava.security.policy=${com.sun.aas.instanceRoot}/config/server.policy',
  '-Djava.security.auth.login.config=${com.sun.aas.instanceRoot}/config/login.conf',
  '-Dcom.sun.enterprise.security.httpsOutboundKeyAlias=s1as',
  '-Djavax.net.ssl.keyStore=${com.sun.aas.instanceRoot}/config/keystore.jks',
  '-Djavax.net.ssl.trustStore=${com.sun.aas.instanceRoot}/config/cacerts.jks',
  '-Djava.ext.dirs=${com.sun.aas.javaRoot}/lib/ext${path.separator}${com.sun.aas.javaRoot}/jre/lib/ext${path.separator}${com.sun.aas.instanceRoot}/lib/ext',
  '-Djdbc.drivers=org.apache.derby.jdbc.ClientDriver',
  '-DANTLR_USE_DIRECT_CLASS_LOADING=true',
  '-Dcom.sun.enterprise.config.config_environment_factory_class=com.sun.enterprise.config.serverbeans.AppserverConfigEnvironmentFactory',
  '-Dorg.glassfish.additionalOSGiBundlesToStart=org.apache.felix.shell,org.apache.felix.gogo.runtime,org.apache.felix.gogo.shell,org.apache.felix.gogo.command,org.apache.felix.fileinstall',
  '-Dosgi.shell.telnet.port=6666',
  '-Dosgi.shell.telnet.maxconn=1',
  '-Dosgi.shell.telnet.ip=127.0.0.1',
  '-Dgosh.args=--nointeractive',
  '-Dfelix.fileinstall.dir=${com.sun.aas.installRoot}/modules/autostart/',
  '-Dfelix.fileinstall.poll=5000',
  '-Dfelix.fileinstall.log.level=2',
  '-Dfelix.fileinstall.bundles.new.start=true',
  '-Dfelix.fileinstall.bundles.startTransient=true',
  '-Dfelix.fileinstall.disableConfigSave=false',
  '-XX:NewRatio=2',
  '-server',
]
