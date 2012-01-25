#
# Cookbook Name:: glassfish
# Attributes:: default
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

default[:glassfish][:user] = "glassfish"
default[:glassfish][:group] = "glassfish-admin"

default[:glassfish][:package_url] = "http://dlc.sun.com.edgesuite.net/glassfish/3.1.1/release/glassfish-3.1.1.zip"
default[:glassfish][:package_checksum] = "8bf4dc016d602e96911456b2e34098b86bae61e2"
default[:glassfish][:base_dir] = "/usr/local/glassfish3"
default[:glassfish][:domains_dir] = "/usr/local/glassfish3/glassfish/domains"
default[:glassfish][:domain_definitions] = Mash.new

default[:openmq][:extra_libraries] = Mash.new
default[:openmq][:instances] = Mash.new
