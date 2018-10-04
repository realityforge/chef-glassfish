if node.linux?
  default['glassfish']['base_dir'] = '/usr/local'
  default['glassfish']['domains_dir'] = '/srv/glassfish'
  default['openmq']['var_home'] = '/var/omq'
end
