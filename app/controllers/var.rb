class Var < Application
  def index
    only_provides :json, :text, :pp

    filter = Hash.new
    params.each do |key, value|
      # skip parameters from merb itself
      next if ["action", "controller", "format", "id"].include?(key)
      next if value == nil

      # If it looks like a regex, treat it like one.
      # That is, if the value is /something/ (begin and end with slash)
      if value =~ /^\/.+\/$/
        filter[key] = Regexp.new(value[1..-2]) rescue value
      else
        # otherwise, treat it like a literal string to full match.
        filter[key] = Regexp.new("^#{Regexp.escape(value)}$")
      end
    end

    # ensure filter isn't changed
    filter.freeze

    @attributes = SlashPort::Component.get_attributes(filter)
    display @attributes
  end
end
