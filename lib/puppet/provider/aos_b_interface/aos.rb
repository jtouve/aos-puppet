require 'puppet/provider/aos'

Puppet::Type.type(:aos_b_interface).provide :aos, :parent => Puppet::Provider::Aos do

  desc "AOS switch/router provider for interface."

  mk_resource_methods

  def self.lookup(device, name)
    interface = nil
    device.command do |dev|
      interface = dev.aos_interface(name)
    end
    interface
  end

  def initialize(device, *args)
    super
  end

  def flush
    device.command do |dev|
      dev.new_aos_interface(name).aos_update(former_properties, properties)
    end
    super
  end
end
