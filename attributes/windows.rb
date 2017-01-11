if node.windows?
  default['glassfish']['base_dir'] = File.join(node[:kernel][:os_info][:system_drive], 'glassfish')
  default['glassfish']['domains_dir'] = File.join(node[:kernel][:os_info][:system_drive], 'glassfish_domains')
  default['openmq']['var_home'] = File.join(node[:kernel][:os_info][:system_drive], 'open_mq')
end
