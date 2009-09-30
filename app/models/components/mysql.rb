require 'rubygems'
require 'sequel'

class SlashPort::Component
  class Mysql < SlashPort::Component

    variable "master-status", :MasterStatus, <<-doc
      Shows the master status of this mysql server
    doc

    variable "stats", :MysqlStats, <<-doc
      Stats from 'show status' in mysql.
    doc

    config "mysql-variables", :ConfigGetVariables, <<-doc
      Output of 'show variables'
    doc

    def initialize
      super
      @db = Sequel.connect("mysql://slashport@localhost")
    end

    def MasterStatus
      data = @db["show master status"].map[0]
      ret = Hash.new
      data.each do |key, val|
        ret[key.to_s.downcase] = val
      end
      return ret
    end 

    def MysqlStats
      result = @db["show global status"]
      data = Hash.new
      result.map do |row|
        value = row[:Value]
        data[row[:Variable_name].downcase] = (Float(value) rescue value)
      end
      return data
    end

    def ConfigGetVariables
      result = @db["show variables"]
      data = Hash.new
      result.map do |row|
        data[row[:Variable_name]] = row[:Value]
      end
      return data
    end # def ConfigGetVariables
  end
end
