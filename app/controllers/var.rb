class Var < Application
  def index
    only_provides :json, :text

    filter = Hash.new
    params.each do |key, value|
      next if ["format", "action"].include?(key)
      next if value == nil
      key = "component" if key == :id
      filter[key] = Regexp.new(value)
    end

    @variables = SlashPort::Component.get_variables(filter)
    display @variables
  end
end
