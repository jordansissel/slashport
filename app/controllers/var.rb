class Var < Application
  def index
    only_provides :json, :text

    filter = Hash.new
    params.each do |key, value|
      # skip parameters from merb itself
      next if ["controller", "format", "action"].include?(key)
      next if value == nil
      filter[key] = Regexp.new(value)
    end

    @variables = SlashPort::Component.get_variables(filter)
    display @variables
  end
end
