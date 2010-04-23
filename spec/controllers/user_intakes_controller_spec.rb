require File.join(File.dirname(__FILE__), "..", "spec_helper")

describe UserIntakesController do

  #Delete these examples and add some real ones
  it "should use UserIntakesController" do
    controller.should be_an_instance_of(UserIntakesController)
  end

  describe "GET 'new'" do
    it "should be successful" do
      get :new
      response.should be_success
    end
  end
end
