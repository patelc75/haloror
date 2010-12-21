require File.join(File.dirname(__FILE__), "..", "spec_helper")

describe DeviceModelPricesController do
  describe "routing" do
    it "recognizes and generates #index" do
      { :get => "/device_model_prices" }.should route_to(:controller => "device_model_prices", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/device_model_prices/new" }.should route_to(:controller => "device_model_prices", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/device_model_prices/1" }.should route_to(:controller => "device_model_prices", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/device_model_prices/1/edit" }.should route_to(:controller => "device_model_prices", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/device_model_prices" }.should route_to(:controller => "device_model_prices", :action => "create") 
    end

    it "recognizes and generates #update" do
      { :put => "/device_model_prices/1" }.should route_to(:controller => "device_model_prices", :action => "update", :id => "1") 
    end

    it "recognizes and generates #destroy" do
      { :delete => "/device_model_prices/1" }.should route_to(:controller => "device_model_prices", :action => "destroy", :id => "1") 
    end
  end
end
