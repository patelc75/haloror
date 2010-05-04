require File.join(File.dirname(__FILE__), "..", "spec_helper")

describe OrdersController do

  #Delete these examples and add some real ones
  it "should use OrdersController" do
    controller.should be_an_instance_of(OrdersController)
  end


  describe "GET 'new'" do
    it "should be successful" do
      get 'new'
      response.should be_success
    end
  end
end
