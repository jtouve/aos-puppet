require 'puppet/provider/aos'

Puppet::Type.type(:interface).provide :aos, :parent => Puppet::Provider::Aos do

  desc "AOS switch/router provider for interface."

  mk_resource_methods

  def self.lookup(device, name)
    interface = nil
    device.command do |dev|
      interface = dev.interface(name)
    end
    interface
  end

  def initialize(device, *args)
    super
  end

  def flush
    device.command do |dev|
      dev.new_interface(name).update(former_properties, properties)
    end
    super
  end
end
