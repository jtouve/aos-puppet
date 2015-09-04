
require 'puppet/util/network_device/aos'
require 'puppet/util/network_device/ipcalc'

class Puppet::Util::NetworkDevice::Aos::Facts

  attr_reader :transport

  def initialize(transport)
    @transport = transport
  end

  def retrieve
    Puppet.debug("retrieving aos facts")
    facts = {}
    facts.merge(parse_show_ver)
  end

  def parse_show_ver
    facts = {}
    
    out = @transport.command("show chassis")
    Puppet.debug("did show chassis")
    lines = out.split("\n")
    lines.each do |l|
        case l
            when /\s+Model Name\:\s+(\w+-\w+)/
                facts[:hardwaremodel] = $1
                Puppet.debug("aos facts: found hardware model #{$1}")
            when /\s+Module Type\:\s+(\w+)/
                facts[:moduletype] = $1
                Puppet.debug("aos facts: found module type #{$1}")
            when /\s+Hardware Revision\:\s+(\w+)/
                facts[:hardwarerevision] = $1
                Puppet.debug("aos facts: found hardware revision #{$1}")
            when /\s+Part Number\:\s+(\w+-\w+)/
                facts[:partnumber] = $1
                Puppet.debug("aos facts: found part number #{$1}")
            when /\s+Serial Number\:\s+(\w+)/
                facts[:serialnumber] = $1
                Puppet.debug("aos facts: found serial number #{$1}")
            when /\s+Manufacture Date\:\s+(\w+)/
                facts[:manufacturedate] = $1
                Puppet.debug("aos facts: found manufacture date #{$1}")
            when /\s+MAC Address\:\s+(\w{2}\:\w{2}\:\w{2}\:\w{2}\:\w{2}\:\w{2})/
                facts[:manufacturedate] = $1
                Puppet.debug("aos facts: found chassis MAC #{$1}")
        end
    end
    
    out = @transport.command("show system")
    Puppet.debug("did show system")
    lines = out.split("\n")
    lines.each do |l|
        case l
            when /\s*Description\:\s+Alcatel-Lucent\s\w+-*\w*+\s(\d+.\d+.\d+.\d+.R\d+\:*\:*\w+*)\s(\w+ \w+)?,\s(\w+\s\d+,\s\d+)/
                facts[:operatingsystem] = "AOS"
                facts[:operatingsystemrelease] = $1
                facts[:operatingsystemreleasedate] = $3
                Puppet.debug("aos facts: found software release #{$1}")
            when /\s*Up Time\:\s+(\d+)\s+days\s+(\d+)\s+hours\s+(\d+)\s+minutes and\s+(\d+)\s+seconds/
                facts[:uptime] = "#{$1} days, #{$2} hours, #{$3}minutes, #{$4} seconds"
                facts[:uptimeseconds] = $1 * 86400 + $2 * 3600 + $3 * 60 + $4 
                facts[:uptimedays] = $1 
                Puppet.debug("aos facts: found up time #{facts[:uptime]}")
            when /\s*Name\:\s+(\w+)/
                facts[:hostname] = $1
                Puppet.debug("aos facts: found host name #{$1}")
            when /\s+Location\:\s+(\w+)/
                facts[:location] = $1
                Puppet.debug("aos facts: found location #{$1}")
        end
    end
    
    facts
  end
end
