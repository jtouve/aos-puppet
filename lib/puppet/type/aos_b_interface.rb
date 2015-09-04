#
# Manages an interface on a given router or switch
#


Puppet::Type.newtype(:aos_b_interface) do

    @doc = "This represents a physical or logial interface on an AOS device. It is possible to manage
    interface mode default vlan and
    switchport characteristics (speed, duplex)."

    apply_to_device

    ensurable do
      defaultvalues

      aliasvalue :shutdown, :absent
      aliasvalue :no_shutdown, :present

      defaultto { :no_shutdown }
    end

    newparam(:name) do
      desc "The interface's name."
    end
    
    newproperty(:alias) do
      desc "Interface Alias."

      defaultto { @resource[:name] }
    end

    newproperty(:default_vlan) do
      desc "Default vlan."
      newvalues(/^\d+/)
    end

    newproperty(:vlan_tags) do
      desc "Static VLAN tags to be applied to this port."
    end

  def present?(current_values)
    super && current_values[:ensure] != :shutdown
  end
end
