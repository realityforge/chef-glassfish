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

# Ensures that a OpenMQ message broker instance has had a chance to finish starting before proceeding.
#
# @action run Block until the broker has come online.
#
# @section Examples
#
#     # Wait for OpenMQ broker to start
#     glassfish_mq_ensure_running "wait for broker" do
#       host "localhost"
#       port 7676
#     end

actions :run
default_action :run

# <> @attribute host The host on which the broker runs.
attribute :host, kind_of: String
# <> @attribute port The port on which the broker listens.
attribute :port, kind_of: Integer
