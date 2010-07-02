require 'spec_helper'

describe UserLogsController do

  #Delete these examples and add some real ones
  it "should use UserLogsController" do
    controller.should be_an_instance_of(UserLogsController)
  end


  describe "GET 'index'" do
    it "should be successful" do
      get 'index'
      response.should be_success
    end
  end

  describe "GET 'show'" do
    it "should be successful" do
      get 'show'
      response.should be_success
    end
  end
end
