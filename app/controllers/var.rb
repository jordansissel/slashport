class Var < Application
  def index
    self.content_type = :text
    return SlashPort::Component.get_variables.to_yaml
  end
end
