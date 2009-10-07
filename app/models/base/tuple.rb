
# A tuple is like a slashport row. 
# Each tuple contains a set of labels and data.
# Each label or data is a key:value pair, allowing you
# to name each label and each data.
#
# For example, transmit packet counts for a network interface would have
# a label of 'interface=eth0', for example, and a data of 'txpackets=12345'
# Multiple labels are supported/encouraged, as are multiple data.
# Following the interface example, you could hold all metrics for a single
# network interface with a single Tuple: ie; 
#   labels: { "interface" => "eth0" }
#   data: { "txpackets" => 298374, "rxpackets" => 7577, "speed" => 1000 }
#
# Labels are intended to represent attributes that will not change.
# Data are intended to represent attributes that can change.
class SlashPort::Tuple
  attr_accessor :labels
  attr_accessor :data
  def initialize
    @labels = Hash.new
    @data = Hash.new
  end

  def to_json
    return {
      "labels" => @labels,
      "data" => @data,
    }.to_json
  end
end
