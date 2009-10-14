require 'rubygems'

class SlashPort::Component
  class LinuxHost < SlashPort::Component
    attribute :name => "uptime",
              :handler => :Uptime,
              :doc => "Uptime in seconds"

    attribute :name => "interfaces",
              :handler => :IfStats,
              :sort => ["interface", "field"],
              :doc => "Interface Statistics"

    attribute :name => "memory",
              :handler => :MemStats,
              :doc => "Memory stats from /proc/meminfo"

    attribute :name => "disk",
              :handler => :DiskStats,
              :doc => "Disk stats from 'df'"

    attribute :name => "load",
              :handler => :LoadAverage,
              :doc => "System load average reported by uptime(1)"

    def Uptime
      tuple = SlashPort::Tuple.new
      tuple.data["uptime"] = File.open("/proc/uptime").read().split(" ")[0]
      return tuple
    end

    def IfStats
      data = Array.new
      File.open("/proc/net/dev").readlines().each do |line|
        line.chomp!
        next if line =~ /^Inter-|^ face/

        tuple = SlashPort::Tuple.new

        fields = %w[rx_bytes rx_packets rx_errors rx_drop rx_fifo rx_frame
                    rx_compressed rx_multicast tx_bytes tx_packets tx_errors
                    tx_drop tx_fifo tx_colls tx_carrier tx_compressed]

        interface, values = line.split(":")
        interface.gsub!(/\s+/, "")
        
        tuple.labels["interface"] = interface
        fields.zip(values.split).each do |field,value|
          tuple.data[field] = value
        end
        data << tuple
      end
      return data
    end

    def MemStats
      data = Array.new
      tuple = SlashPort::Tuple.new
      File.open("/proc/meminfo").readlines().each do |line|
        line.chomp!
        key, value, unit = line.split(/[: ]+/)
        value = value.to_i
        if unit == "kB"
          value *= 1024
        end

        tuple.data[key.downcase] = value
      end
      data << tuple
      return data
    end # def MemStats

    def DiskStats
      data = Array.new
      IO.popen("df -PlB 1").readlines().each do |line|
        # skip header
        next if line =~ /Filesystem\s/
        # skip nonpath sources (tmpfs, udev, etc)
        next unless line =~ /^\//

        line.chomp!
        tuple = SlashPort::Tuple.new
        fields = %w[size used available percentused]
        values = line.split
        source = values.shift
        mount = values.pop

        tuple.labels["source"] = source
        tuple.labels["mount"] = mount
        fields.zip(values).each do |field,value|
          if field == "percentused"
            value = value.to_i / 100.0
          end

          tuple.data[field] = value
        end
        data << tuple
      end
      Process.wait(-1, Process::WNOHANG)
      return data
    end # def DiskStats
  end

  def LoadAverage
    data = Array.new
    tuple = SlashPort::Tuple.new
    loads = %x{uptime}.chomp.delete(",").split(/ +/)[-3..-1].map { |x| x.to_f }
    Process.wait(-1, Process::WNOHANG)
    load1, load5, load15 = loads
    tuple.data["load-1min"] = load1
    tuple.data["load-5min"] = load5
    tuple.data["load-15min"] = load15

    data << tuple
    return data
  end
end
