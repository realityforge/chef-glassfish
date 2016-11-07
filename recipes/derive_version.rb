if node['glassfish']['package_url'].nil?
  variant = node['glassfish']['variant']
  version = node['glassfish']['version']

  node.override['glassfish']['package_url'] = node['glassfish']['package_urls'][variant][version]
end

raise "glassfish.package_url not specified and unable to be derived. Please specify an attribute value for node['glassfish']['package_url']" if node['glassfish']['package_url'].nil?
