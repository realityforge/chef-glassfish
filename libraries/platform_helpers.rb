class Chef::Node
  def windows?
    self['os'] == 'windows'
  end

  def linux?
    self['os'] == 'linux'
  end
end
