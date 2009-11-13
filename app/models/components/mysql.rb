require 'rubygems'
require 'sequel'

class SlashPort::Component
  class Mysql < SlashPort::Component
    attr_accessor :host
    attr_accessor :user
    attr_accessor :password

    attribute :name => "master_status",
              :handler => :MasterStatus,
              :doc => "Shows the master status of this mysql server"

    attribute :name => "slave_status",
              :handler => :SlaveStatus,
              :doc => "Shows the slave status of this mysql server"

    attribute :name => "stats",
              :handler => :MysqlStats,
              :doc => "Stats from 'show status' in mysql."

    attribute :name => "connection", 
              :handler => :MysqlOK,
              :doc => "Reports whether we can send queries successfully to mysql."

    def initialize
      super
      begin
        @db = Sequel.connect("mysql://slashport@localhost")
      rescue Sequel::AdapterNotFound => e
        puts "Disabling #{self.class.label} component: missing mysql Sequel adapter: #{e.inspect}"
        self.class.disable
      end
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
        return nil
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
          tuple.data["is_slave"] = false
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
