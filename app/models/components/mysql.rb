require 'rubygems'
require 'sequel'
require 'mysql' # for mysql errors

class SlashPort::Component
  class Mysql < SlashPort::Component

    multivariable "master-status", :MasterStatus, <<-doc
      Shows the master status of this mysql server
    doc

    multivariable "slave-status", :SlaveStatus, <<-doc
      Shows the slave status of this mysql server
    doc

    multivariable "stats", :MysqlStats, <<-doc
      Stats from 'show status' in mysql.
    doc

    variable "connection_ok", :MysqlOK, <<-doc
      Reports whether we can send queries successfully to mysql.
    doc

    multiconfig "settings", :ConfigGetVariables, <<-doc
      Output of 'show variables'
    doc

    def initialize
      super
      @db = Sequel.connect("mysql://slashport@localhost")
    end

    def MysqlOK
      begin
        # dummy query just to test our connection
        @db["show variables like 'x'"].map
        return true
      rescue Sequel::DatabaseConnectionError, Sequel::DatabaseError
        return false
      end
    end # end MysqlOK

    def MasterStatus
      begin
        data = @db["show master status"].map[0]
        ret = Hash.new
        data.each do |key, val|
          ret[key.to_s.downcase] = val
        end
        return ret
      rescue Sequel::DatabaseConnectionError, Sequel::DatabaseError
        return nil
      end
    end # end MasterStatus

    def SlaveStatus
      begin
        data = @db["show slave status"].map[0]
        ret = Hash.new
        if data == nil
          # this host is not a slave
          ret["is-slave"] = false
        else
          data.each do |key, val|
            ret[key.to_s.downcase] = val
          end
        end
        return ret
      rescue Sequel::DatabaseConnectionError, Sequel::DatabaseError
        return nil
      end
    end # end MasterStatus

    def MysqlStats
      begin
        result = @db["show global status"]
        data = Hash.new
        result.map do |row|
          value = row[:Value]
          # use actual value if Float fails.
          data[row[:Variable_name].downcase] = (Float(value) rescue value)
        end
        return data
      rescue Sequel::DatabaseConnectionError, Sequel::DatabaseError
        return nil
      end
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
