require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe "/config" do
  before(:each) do
    @response = request("/config")
  end
end