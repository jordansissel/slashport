require 'rubygems'

class SlashPort::Component
  class Puppet < SlashPort::Component
    attribute :name => "freshness",
              :handler => :freshness,
              :doc => "Freshness according to puppet's localconfig.yaml "

    def freshness
      begin
        tuple = SlashPort::Tuple.new
        age = Time.now - File.stat("/var/puppet/state/localconfig.yaml")
        tuple.data["freshness"] = age.to_f
        return tuple
      rescue Errno::ENOENT
        return nil
      end
    end # def freshness
  end # class Puppet
end
