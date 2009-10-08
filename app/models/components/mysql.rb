require 'rubygems'
require 'sequel'
require 'mysql' # for mysql errors

class SlashPort::Component
  class Mysql < SlashPort::Component
    attr_accessor :host
    attr_accessor :user
    attr_accessor :password

    attribute :name => "master-status",
              :handler => :MasterStatus,
              :doc => "Shows the master status of this mysql server"

    attribute :name => "slave-status",
              :handler => :SlaveStatus,
              :doc => "Shows the slave status of this mysql server"

    attribute :name => "stats",
              :handler => :MysqlStats,
              :doc => "Stats from 'show status' in mysql."

    attribute :name => "connection", 
              :handler => :MysqlOK,
              :doc => "Reports whether we can send queries successfully to mysql."

    #multiconfig "settings", :ConfigGetVariables, <<-doc
      #Output of 'show variables'
    #doc

    def initialize
      super
      @db = Sequel.connect("mysql://slashport@localhost")
    end

    def MysqlOK
      tuple = SlashPort::Tuple.new
      begin
        # dummy query just to test our connection
        @db["show variables like 'x'"].map
        tuple.data["healthy"] = 1
      rescue Sequel::DatabaseConnectionError, Sequel::DatabaseError
        tuple.data["healthy"] = 0
      end
      return tuple
    end # end MysqlOK

    def MasterStatus
      data = []
      tuple = SlashPort::Tuple.new
      begin
        result = @db["show master status"].map[0]
        result.each do |key, val|
          tuple.data[key.to_s.downcase] = val
        end
        data << tuple
      rescue Sequel::DatabaseConnectionError, Sequel::DatabaseError
        # ignore
      end
      return data
    end # end MasterStatus

    def SlaveStatus
      tuple = SlashPort::Tuple.new
      begin
        result = @db["show slave status"].map[0]
        ret = Hash.new
        if result == nil
          # this host is not a slave
          tuple.data["is-slave"] = false
        else
          result.each do |key, val|
            tuple.data[key.to_s.downcase] = val
          end
        end
      rescue Sequel::DatabaseConnectionError, Sequel::DatabaseError
        return nil
      end
      return tuple
    end # end MasterStatus

    def MysqlStats
      tuple = SlashPort::Tuple.new
      begin
        result = @db["show global status"]
        result.map do |row|
          value = row[:Value]
          # use actual value if Float fails.
          tuple.data[row[:Variable_name].downcase] = (Float(value) rescue value)
        end
      rescue Sequel::DatabaseConnectionError, Sequel::DatabaseError
        return nil
      end
      return tuple
    end # end MysqlStats

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
