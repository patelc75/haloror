require File.join(File.dirname(__FILE__), "..", "spec_helper")

describe TriageThresholdsController do
  describe "routing" do
    it "recognizes and generates #index" do
      { :get => "/triage_thresholds" }.should route_to(:controller => "triage_thresholds", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/triage_thresholds/new" }.should route_to(:controller => "triage_thresholds", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/triage_thresholds/1" }.should route_to(:controller => "triage_thresholds", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/triage_thresholds/1/edit" }.should route_to(:controller => "triage_thresholds", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/triage_thresholds" }.should route_to(:controller => "triage_thresholds", :action => "create") 
    end

    it "recognizes and generates #update" do
      { :put => "/triage_thresholds/1" }.should route_to(:controller => "triage_thresholds", :action => "update", :id => "1") 
    end

    it "recognizes and generates #destroy" do
      { :delete => "/triage_thresholds/1" }.should route_to(:controller => "triage_thresholds", :action => "destroy", :id => "1") 
    end
  end
end
