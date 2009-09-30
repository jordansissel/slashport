class Cfg < Application

  def index
    self.content_type = :text
    return SlashPort::Component.get_configs.to_yaml
  end

end
