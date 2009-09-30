require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe "/vardoc" do
  before(:each) do
    @response = request("/vardoc")
  end
end