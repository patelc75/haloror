require 'spec_helper'

describe DeviceModelPricesController do

  def mock_device_model_price(stubs={})
    @mock_device_model_price ||= mock_model(DeviceModelPrice, stubs)
  end

  describe "GET index" do
    it "assigns all device_model_prices as @device_model_prices" do
      DeviceModelPrice.stub(:find).with(:all).and_return([mock_device_model_price])
      get :index
      assigns[:device_model_prices].should == [mock_device_model_price]
    end
  end

  describe "GET show" do
    it "assigns the requested device_model_price as @device_model_price" do
      DeviceModelPrice.stub(:find).with("37").and_return(mock_device_model_price)
      get :show, :id => "37"
      assigns[:device_model_price].should equal(mock_device_model_price)
    end
  end

  describe "GET new" do
    it "assigns a new device_model_price as @device_model_price" do
      DeviceModelPrice.stub(:new).and_return(mock_device_model_price)
      get :new
      assigns[:device_model_price].should equal(mock_device_model_price)
    end
  end

  describe "GET edit" do
    it "assigns the requested device_model_price as @device_model_price" do
      DeviceModelPrice.stub(:find).with("37").and_return(mock_device_model_price)
      get :edit, :id => "37"
      assigns[:device_model_price].should equal(mock_device_model_price)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created device_model_price as @device_model_price" do
        DeviceModelPrice.stub(:new).with({'these' => 'params'}).and_return(mock_device_model_price(:save => true))
        post :create, :device_model_price => {:these => 'params'}
        assigns[:device_model_price].should equal(mock_device_model_price)
      end

      it "redirects to the created device_model_price" do
        DeviceModelPrice.stub(:new).and_return(mock_device_model_price(:save => true))
        post :create, :device_model_price => {}
        response.should redirect_to(device_model_price_url(mock_device_model_price))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved device_model_price as @device_model_price" do
        DeviceModelPrice.stub(:new).with({'these' => 'params'}).and_return(mock_device_model_price(:save => false))
        post :create, :device_model_price => {:these => 'params'}
        assigns[:device_model_price].should equal(mock_device_model_price)
      end

      it "re-renders the 'new' template" do
        DeviceModelPrice.stub(:new).and_return(mock_device_model_price(:save => false))
        post :create, :device_model_price => {}
        response.should render_template('new')
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested device_model_price" do
        DeviceModelPrice.should_receive(:find).with("37").and_return(mock_device_model_price)
        mock_device_model_price.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :device_model_price => {:these => 'params'}
      end

      it "assigns the requested device_model_price as @device_model_price" do
        DeviceModelPrice.stub(:find).and_return(mock_device_model_price(:update_attributes => true))
        put :update, :id => "1"
        assigns[:device_model_price].should equal(mock_device_model_price)
      end

      it "redirects to the device_model_price" do
        DeviceModelPrice.stub(:find).and_return(mock_device_model_price(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(device_model_price_url(mock_device_model_price))
      end
    end

    describe "with invalid params" do
      it "updates the requested device_model_price" do
        DeviceModelPrice.should_receive(:find).with("37").and_return(mock_device_model_price)
        mock_device_model_price.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :device_model_price => {:these => 'params'}
      end

      it "assigns the device_model_price as @device_model_price" do
        DeviceModelPrice.stub(:find).and_return(mock_device_model_price(:update_attributes => false))
        put :update, :id => "1"
        assigns[:device_model_price].should equal(mock_device_model_price)
      end

      it "re-renders the 'edit' template" do
        DeviceModelPrice.stub(:find).and_return(mock_device_model_price(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested device_model_price" do
      DeviceModelPrice.should_receive(:find).with("37").and_return(mock_device_model_price)
      mock_device_model_price.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the device_model_prices list" do
      DeviceModelPrice.stub(:find).and_return(mock_device_model_price(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(device_model_prices_url)
    end
  end

end
