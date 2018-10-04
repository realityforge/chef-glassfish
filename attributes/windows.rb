if node.windows?
  node.default['glassfish']['base_dir'] = node['kernel']['os_info']['system_drive']
  node.default['glassfish']['domains_dir'] = File.join(node['kernel']['os_info']['system_drive'], 'glassfish_domains')
  node.default['openmq']['var_home'] = File.join(node['kernel']['os_info']['system_drive'], 'open_mq')
end
