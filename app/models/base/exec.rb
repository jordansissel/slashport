class SlashPort::Exec
  def initialize(cmd)
    @cmd = cmd
  end

  def run
    output = `#{@cmd}`
    code = $?.exitstatus

    return [output, code]
  end

  def to_tuple
    data = []

    output, code = run
    lines = output.split(/\r?\n/)

    if lines.length == 0
      tuple = SlashPort::Tuple.new
      tuple.data["output-lines"] = lines.length
      tuple.data["exit-code"] = code
      data << tuple
    end

    lines.each do |line|
      tuple = SlashPort::Tuple.new
      tuple.data["exit-code"] = code
      begin
        tuple.data["value"] = Float(line)
      rescue ArgumentError => e
        tuple.labels["string"] = 1
        tuple.data["value"] = line
      end

      data << tuple
    end
    return data
  end
end
