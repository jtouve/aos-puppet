#
# Manages a Vlan on a given router or switch
# Alphabetized to ensure proper execution order for AOS
#

Puppet::Type.newtype(:aos_a_vlan) do
    @doc = "Manages a VLAN on an Alcatel-Lucent AOS Device."

    apply_to_device

    ensurable

    newparam(:name) do
      desc "The numeric VLAN ID."
      isnamevar

      newvalues(/^\d+/)
    end

    newproperty(:description) do
      desc "The VLAN's name/description."
    end
    
    newproperty(:admin_status) do
      desc "The admin status of the VLAN, enable or disable."
      defaultto(:absent)
      newvalues(:absent, :enable, :disable)
    end

end
