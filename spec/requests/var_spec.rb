require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe "/var" do
  before(:each) do
    @response = request("/var")
  end
end