if node.linux?
  default['glassfish']['base_dir'] = '/usr/local/glassfish'
  default['glassfish']['domains_dir'] = '/srv/glassfish'
  default['openmq']['var_home'] = '/var/omq'
end
