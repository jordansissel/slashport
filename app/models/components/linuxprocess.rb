require 'rubygems'

class SlashPort::Component::LinuxProcess < SlashPort::Component
  def self.add_process(name, &pid_method)
    define_method(name.to_sym) do
      pid = pid_method.call().to_i
      query_process(pid)
    end

    attribute :name => name,
              :handler => name.to_sym,
              :doc => "Process data for #{name}"
  end

  def query_process(pid)
    procinfo = ProcessInfo.new(pid)
    limits = procinfo.get_limits
    tuple = SlashPort::Tuple.new
    puts limits.inspect
    tuple.data["max_open_files"] = limits["open files"]
    tuple.data["open_files"] = procinfo.open_files
    return tuple
  end

end # class SlashPort::Component


class ProcessInfo
  def initialize(pid)
    @pid = pid
  end

  def procpath(path)
    return "/proc/#{@pid}/#{path}"
  end

  def get_limits
    linere = /^Max (.*?) +\S+ +(\S+)(?: +\S+\s*)?$/
    limits = Hash.new
    File.open(procpath("limits")).each do |line|
      line.chomp!
      next if line =~ /^Limit/
      puts line
      match = linere.match(line)
      next if match == nil
      limits[match.captures[0]] = match.captures[1]
    end
    return limits
  end

  def open_files
    return Dir.glob(procpath("fd/*")).length
  end

end
