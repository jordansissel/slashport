require 'rubygems'

class SlashPort::Component
  class LinuxHost < SlashPort::Component
    variable :name => "uptime", :handler => :Uptime, :doc => "Uptime in seconds"
    variable :name => "interfaces",
             :handler => :IfStats,
             :sort => ["interface", "field"],
             :doc => "Interface Statistics"

    variable :name => "memory",
             :handler => :MemStats,
             :doc => "Memory stats from /proc/meminfo"

    variable :name => "disk",
             :handler => :DiskStats,
             :doc => "Disk stats from 'df'"

    def Uptime
      return File.open("/proc/uptime").read().split(" ")[0]
    end

    def IfStats
      data = Array.new
      File.open("/proc/net/dev").readlines().each do |line|
        line.chomp!
        next if line =~ /^Inter-|^ face/
        fields = %w[rx_bytes rx_packets rx_errors rx_drop rx_fifo rx_frame
                    rx_compressed rx_multicast tx_bytes tx_packets tx_errors
                    tx_drop tx_fifo tx_colls tx_carrier tx_compressed]

        interface, values = line.split(":")
        interface.gsub!(/\s+/, "")
        fields.zip(values.split).each do |field,value|
          data << {
            "interface" => interface,
            "field" => field,
            "value" => value,
          }
        end
      end
      return data
    end

    def MemStats
      data = Array.new
      File.open("/proc/meminfo").readlines().each do |line|
        line.chomp!
        key, value, unit = line.split(/[: ]+/)
        value = value.to_i
        if unit == "kB"
          value *= 1024
        end

        data << {
          "field" => key.downcase,
          "value" => value,
        }
      end
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
        fields = %w[size, used, available, percentused]
        values = line.split
        source = values.shift
        mount = values.pop

        fields.zip(values).each do |field,value|
          if field == "percentused"
            value = value.to_i / 100.0
          end

          data << {
            "source" => source,
            "mount" => mount,
            "field" => field,
            "value" => value,
          }
        end
      end
      return data
    end # def DiskStats
  end
end
