class Var < Application
  def index
    only_provides :json, :text
    @variables = SlashPort::Component.get_variables(params)
    display @variables
  end
end
