default['glassfish']['network_listeners']['http-listener-1'] =
{
  'listenerport' => 8080,
  'threadpool' => 'http-thread-pool',
  'protocol' => 'http-listener-1',
  'transport' => 'tcp'
}
default['glassfish']['network_listeners']['http-listener-2'] =
{
  'listenerport' => 8181,
  'threadpool' => 'http-thread-pool',
  'protocol' => 'http-listener-2',
  'transport' => 'tcp'
}
default['glassfish']['network_listeners']['admin-listener'] =
{
  'listenerport' => 4848,
  'threadpool' => 'http-thread-pool',
  'protocol' => 'admin-listener',
  'transport' => 'tcp'
}
