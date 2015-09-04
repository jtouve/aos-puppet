require 'puppet'
require 'puppet/util'
require 'puppet/util/network_device/base'
require 'puppet/util/network_device/ipcalc'
require 'puppet/util/network_device/aos/interface'
require 'puppet/util/network_device/aos/facts'
require 'ipaddr'

class Puppet::Util::NetworkDevice::Aos::Device < Puppet::Util::NetworkDevice::Base

  include Puppet::Util::NetworkDevice::IPCalc

  attr_accessor :enable_password

  def initialize(url, options = {})
    super(url, options)
    transport.default_prompt = /[#>]\s?\z/n
  end

  def connect
    transport.connect
    login
  end

  def disconnect
    transport.close
  end

  def command(cmd = nil)
    connect
    out = execute(cmd) if cmd
    yield self if block_given?
    disconnect
    out
  end

  def execute(cmd)
    transport.command(cmd)
  end

  def login
    return if transport.handles_login?
    if @url.user != ''
      transport.command(@url.user, :prompt => /^Password:/)
    else
      transport.expect(/^Password:/)
    end
    transport.command(@url.password)
  end

  def facts
    Puppet.debug("creating aos facts")
    @facts ||= Puppet::Util::NetworkDevice::Aos::Facts.new(transport)
    facts = {}
    command do |ng|
      facts = @facts.retrieve
    end
    facts
  end

  def aos_interface(name)
    interface = parse_aos_interface(name)
    return { :ensure => :absent } if interface.empty?
  end

  def new_aos_interface(name)
    Puppet::Util::NetworkDevice::Aos::Interface.new(name, transport)
  end

  def parse_aos_interface(name)
    resource = {}
    #get the default vlan
    Puppet.debug("getting default VLAN of #{name}")
    out = execute("show vlan members port #{name}")
    lines = out.split("\n")
    lines.each do |l|
      if l =~ /\s+(\d+)\s+default\s.+/
        resource[:ensure] = :present 
        resource[:default_vlan] = $1 
        Puppet.debug("default VLAN of #{name} is #{$1}")
      end
    end
    # get the alias
    Puppet.debug("getting alias of #{name}")
    out = execute("show interfaces #{name} alias")
    lines = out.split("\n")
    lines.each do |l|
      if l =~ /\s+#{name}\s+\w+\s+\w+\s+\d+\s+\d+\s+\"(.+)\"/
        resource[:alias] = $1 
        Puppet.debug("alias of #{name} is #{$1}")
      end
    end
    #get the tag list
    Puppet.debug("getting tagged vlans of #{name}")
    tags = {}
    out = execute("show vlan members port #{name}")
    lines = out.split("\n")
    lines.each do |l|
      if l =~ /\s+(\d+)\s+qtagged\s.+/
        tags[$1] = $1 
        Puppet.debug("#{$1} is tagged on #{name}")
      end
    end
    tagslist = tags.values
    Puppet.debug("found #{tagslist.length} tagged vlans of #{name}")
    resource[:vlan_tags] = tagslist.join(',')
    Puppet.debug("list of tagged vlans for #{name} is #{resource[:vlan_tags]}")
    resource
  end

  
  def parse_aos_vlans
    vlans = {}
    Puppet.debug("parsing aos VLANs")
    out = execute("show vlans")
    lines = out.split("\n")
    vlan = nil
    lines.each do |l|
      if l =~ /^(\d+)\s+\w+\s+(\w+)\s+\w+\s+\w+\s+\d+\s+(.+)/
        vlan = { :name => $1, :admin_status => $2, :description => $3, }
        vlans[vlan[:name]] = vlan
        Puppet.debug("found VLAN #{$1}")
      else
      end
    end
    vlans
  end

  def update_aos_vlan(id, is = {}, should = {})
    if should[:ensure] == :absent
      Puppet.info "Removing #{id} from device vlan"
      execute("no vlan #{id}")
      return
    end
    
    Puppet.debug("creating VLAN: #{id}")
    execute("vlan #{id}")
    [is.keys, should.keys].flatten.uniq.each do |property|
      if property == :description
        execute("vlan #{id} name #{should[:description]}")
      elsif property == :admin_status
        if should[:admin_status] != :absent 
          case should[:admin_status]
            when :enable
                execute("vlan #{id} admin-state enable")
            when :disable
                execute("vlan #{id} admin-state disable")
            else    
          end
        end
      end

    end
  end

end
