require 'puppet/util/network_device/aos/device'
require 'puppet/provider/network_device'

# This is the base class of all prefetched AOS device providers
class Puppet::Provider::Aos < Puppet::Provider::NetworkDevice
  def self.device(url)
    Puppet::Util::NetworkDevice::Aos::Device.new(url)
  end
end
