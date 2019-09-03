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

action :download do
  archive_exists = ::File.exists?(new_resource.target_artifact)

  Chef::Log.info "Archive #{new_resource.name} => #{new_resource.target_artifact} Exists? #{archive_exists}"

  unless archive_exists

    cached_package_filename = nil
    delete_cached_package = true
    if new_resource.url =~ /^file\:\/\//
      cached_package_filename = new_resource.url[7, new_resource.url.length]
      delete_cached_package = false
    else
      cached_package_filename = "#{Chef::Config[:file_cache_path]}/#{new_resource.local_filename}"

      sensitive = new_resource.headers.empty? ? false : true
      remote_file cached_package_filename do
        source new_resource.url
        owner new_resource.owner
        group new_resource.group
        headers new_resource.headers
        sensitive sensitive
        mode '0600'
        action :create_if_missing
      end
    end

    [new_resource.base_directory, new_resource.package_directory, new_resource.target_directory].each do |dir|
      directory dir do
        owner new_resource.owner
        group new_resource.group
        mode new_resource.mode
        recursive (new_resource.base_directory == dir)
        action :create
        not_if { ::File.exists?(new_resource.base_directory) && dir == new_resource.base_directory }
      end
    end

    bash 'move_package' do
      user new_resource.owner
      group new_resource.group
      umask new_resource.umask if new_resource.umask
      code "cp #{cached_package_filename} #{new_resource.target_artifact}"
    end
  end
end

action :unzip_and_strip_dir do
    package 'unzip'
    archive_exists = ::File.exists?(new_resource.target_directory)

    unless archive_exists
      # Download the archive from remote
      action_download

      # Unzip the archive
      archive_path = new_resource.target_artifact
      temp_dir = "/tmp/install-#{new_resource.name}-#{new_resource.derived_version}"
      bash 'unzip_package' do
        not_if { archive_exists }
        user new_resource.owner
        group new_resource.group
        umask new_resource.umask if new_resource.umask
        code <<-CMD
          set -e
          rm -rf #{temp_dir}
          mkdir #{temp_dir}
          unzip -q -u -o #{archive_path} -d #{temp_dir}
          if [ `ls -1 #{temp_dir} |wc -l` -gt 1 ] ; then
            echo More than one directory found
            exit 37
          fi
          mv #{temp_dir}/*/* #{new_resource.target_directory} && rm -rf #{temp_dir} && test -d #{new_resource.target_directory}
        CMD
      end

      # Delete the original archive
      file archive_path do
        backup false
        action :delete
      end

      # Create the symlink
      current_directory = "#{new_resource.package_directory}/current"
      last_version = ::File.exist?(current_directory) ? ::File.readlink(current_directory) : nil
      link current_directory do
        to new_resource.target_directory
        owner new_resource.owner
        group new_resource.group
      end
    end
end
