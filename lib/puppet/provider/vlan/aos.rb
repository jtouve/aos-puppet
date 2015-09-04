require 'puppet/provider/aos'

Puppet::Type.type(:vlan).provide :aos, :parent => Puppet::Provider::Aos do

  desc "Aos switch/router provider for vlans."

  mk_resource_methods

  def self.lookup(device, id)
    vlans = {}
    device.command do |dev|
      vlans = dev.parse_vlans || {}
    end
    vlans[id]
  end

  def initialize(device, *args)
    super
  end

  # Clear out the cached values.
  def flush
    device.command do |dev|
      dev.update_vlan(resource[:name], former_properties, properties)
    end
    super
  end
end
