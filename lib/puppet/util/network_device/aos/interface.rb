require 'puppet/util/network_device/aos'
require 'puppet/util/network_device/ipcalc'

# this manages setting properties to an interface in a cisco switch or router
class Puppet::Util::NetworkDevice::Aos::Interface

  include Puppet::Util::NetworkDevice::IPCalc
  extend Puppet::Util::NetworkDevice::IPCalc

  attr_reader :transport, :name

  def initialize(name, transport)
    @name = name
    @transport = transport
  end
  
  def aos_update(is={}, should={})
    Puppet.debug("updating aos interface #{name}")

    [is.keys, should.keys].flatten.uniq.each do |property|
      # they're equal, so do nothing.
      next if is[property] == should[property]
      if property == :alias
        if should[property] == :absent or should[property].nil?
          Puppet.debug("reset alias of interface #{name}")
          command("interfaces #{name} alias \"\"")
        else
          Puppet.debug("setting alias of interface #{name} to #{should[property]}")
          command("interfaces #{name} alias #{should[property]}")
        end
        next
      end
      if property == :default_vlan
        if should[property] == :absent or should[property].nil?
          Puppet.debug("reset default vlan of interface #{name} to 1")
          command("vlan 1 members port #{name} untagged")
        else
          Puppet.debug("setting default vlan of interface #{name} to #{should[property]}")
          command("vlan #{should[property]} members port #{name} untagged")
        end  
        next
      end
      if property == :vlan_tags
        new_tags_st = String.new("#{should[:vlan_tags]}")
        old_tags_st = String.new("#{is[:vlan_tags]}")
        Puppet.debug("checking tags on #{name} old tags = #{old_tags_st} new tags = #{new_tags_st}")
        new_tags = new_tags_st.split(",")
        old_tags = old_tags_st.split(",")
        #first add new tags to port
        add_tags = new_tags - old_tags
        add_tags.each do |v|
          Puppet.debug("adding tag #{v} to #{name}")
          command("vlan #{v} members port #{name} tagged")
        end
        #now remove any missing vlans from should
        del_tags = old_tags - new_tags
        del_tags.each do |v|
          Puppet.debug("deleting tag #{v} from #{name}")
          command("no vlan #{v} members port #{name}")
        end
        next
      end
    end

  end

  def command(command)
    transport.command(command) do |out|
      Puppet.err "Error while executing #{command}, device returned #{out}" if out =~ /^%/mo
    end
  end
end
