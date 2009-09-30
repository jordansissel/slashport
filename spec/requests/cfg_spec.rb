require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe "/cfg" do
  before(:each) do
    @response = request("/cfg")
  end
end