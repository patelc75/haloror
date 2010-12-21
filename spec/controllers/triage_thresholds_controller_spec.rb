require File.join(File.dirname(__FILE__), "..", "spec_helper")

describe TriageThresholdsController do

  def mock_triage_threshold(stubs={})
    @mock_triage_threshold ||= mock_model(TriageThreshold, stubs)
  end

  # this has group search added. need to change this test
  # describe "GET index" do
  #   it "assigns all triage_thresholds as @triage_thresholds" do
  #     TriageThreshold.stub(:find).with(:all).and_return([mock_triage_threshold])
  #     get :index
  #     assigns[:triage_thresholds].should == [mock_triage_threshold]
  #   end
  # end

  # describe "GET show" do
  #   it "assigns the requested triage_threshold as @triage_threshold" do
  #     TriageThreshold.stub(:find).with("37").and_return(mock_triage_threshold)
  #     get :show, :id => "37"
  #     assigns[:triage_threshold].should equal(mock_triage_threshold)
  #   end
  # end

  # describe "GET new" do
  #   it "assigns a new triage_threshold as @triage_threshold" do
  #     TriageThreshold.stub(:new).and_return(mock_triage_threshold)
  #     get :new
  #     assigns[:triage_threshold].should equal(mock_triage_threshold)
  #   end
  # end

  # describe "GET edit" do
  #   it "assigns the requested triage_threshold as @triage_threshold" do
  #     TriageThreshold.stub(:find).with("37").and_return(mock_triage_threshold)
  #     get :edit, :id => "37"
  #     assigns[:triage_threshold].should equal(mock_triage_threshold)
  #   end
  # end

  describe "POST create" do

    # describe "with valid params" do
    #   it "assigns a newly created triage_threshold as @triage_threshold" do
    #     TriageThreshold.stub(:new).with({'these' => 'params'}).and_return(mock_triage_threshold(:save => true))
    #     post :create, :triage_threshold => {:these => 'params'}
    #     assigns[:triage_threshold].should equal(mock_triage_threshold)
    #   end

    #   it "redirects to the created triage_threshold" do
    #     TriageThreshold.stub(:new).and_return(mock_triage_threshold(:save => true))
    #     post :create, :triage_threshold => {}
    #     response.should redirect_to(triage_threshold_url(mock_triage_threshold))
    #   end
    # end

    # describe "with invalid params" do
    #   it "assigns a newly created but unsaved triage_threshold as @triage_threshold" do
    #     TriageThreshold.stub(:new).with({'these' => 'params'}).and_return(mock_triage_threshold(:save => false))
    #     post :create, :triage_threshold => {:these => 'params'}
    #     assigns[:triage_threshold].should equal(mock_triage_threshold)
    #   end
    # 
    #   it "re-renders the 'new' template" do
    #     TriageThreshold.stub(:new).and_return(mock_triage_threshold(:save => false))
    #     post :create, :triage_threshold => {}
    #     response.should render_template('new')
    #   end
    # end

  end

  describe "PUT update" do

    # describe "with valid params" do
    #   it "updates the requested triage_threshold" do
    #     TriageThreshold.should_receive(:find).with("37").and_return(mock_triage_threshold)
    #     mock_triage_threshold.should_receive(:update_attributes).with({'these' => 'params'})
    #     put :update, :id => "37", :triage_threshold => {:these => 'params'}
    #   end
    # 
    #   it "assigns the requested triage_threshold as @triage_threshold" do
    #     TriageThreshold.stub(:find).and_return(mock_triage_threshold(:update_attributes => true))
    #     put :update, :id => "1"
    #     assigns[:triage_threshold].should equal(mock_triage_threshold)
    #   end
    # 
    #   it "redirects to the triage_threshold" do
    #     TriageThreshold.stub(:find).and_return(mock_triage_threshold(:update_attributes => true))
    #     put :update, :id => "1"
    #     response.should redirect_to(triage_threshold_url(mock_triage_threshold))
    #   end
    # end

    # describe "with invalid params" do
    #   it "updates the requested triage_threshold" do
    #     TriageThreshold.should_receive(:find).with("37").and_return(mock_triage_threshold)
    #     mock_triage_threshold.should_receive(:update_attributes).with({'these' => 'params'})
    #     put :update, :id => "37", :triage_threshold => {:these => 'params'}
    #   end
    # 
    #   it "assigns the triage_threshold as @triage_threshold" do
    #     TriageThreshold.stub(:find).and_return(mock_triage_threshold(:update_attributes => false))
    #     put :update, :id => "1"
    #     assigns[:triage_threshold].should equal(mock_triage_threshold)
    #   end
    # 
    #   # it "re-renders the 'edit' template" do
    #   #   TriageThreshold.stub(:find).and_return(mock_triage_threshold(:update_attributes => false))
    #   #   put :update, :id => "1"
    #   #   response.should render_template('edit')
    #   # end
    # end

  end

  # describe "DELETE destroy" do
  #   it "destroys the requested triage_threshold" do
  #     TriageThreshold.should_receive(:find).with("37").and_return(mock_triage_threshold)
  #     mock_triage_threshold.should_receive(:destroy)
  #     delete :destroy, :id => "37"
  #   end
  # 
  #   it "redirects to the triage_thresholds list" do
  #     TriageThreshold.stub(:find).and_return(mock_triage_threshold(:destroy => true))
  #     delete :destroy, :id => "1"
  #     response.should redirect_to(triage_thresholds_url)
  #   end
  # end

end
