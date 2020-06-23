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

require 'socket'

action :run do
  ruby_block 'block_until_running' do
    block do
      count = 0
      loop do
        raise 'OpenMQ broker never came online' if count > 50
        begin
          s = TCPSocket.new new_resource.host, new_resource.port
          break
        rescue Errno::ECONNREFUSED
          Chef::Log.debug "OpenMQ broker not running, attempt #{count}"
        ensure
          s.close unless s.nil?
        end
        count += 1
        sleep 1
      end
    end
  end
end
