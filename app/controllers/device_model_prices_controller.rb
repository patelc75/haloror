class DeviceModelPricesController < ApplicationController
  # GET /device_model_prices
  # GET /device_model_prices.xml
  def index
    @device_model_prices = DeviceModelPrice.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @device_model_prices }
    end
  end

  # GET /device_model_prices/1
  # GET /device_model_prices/1.xml
  def show
    @device_model_price = DeviceModelPrice.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @device_model_price }
    end
  end

  # GET /device_model_prices/new
  # GET /device_model_prices/new.xml
  def new
    @device_model_price = DeviceModelPrice.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @device_model_price }
    end
  end

  # GET /device_model_prices/1/edit
  def edit
    @device_model_price = DeviceModelPrice.find(params[:id])
  end

  # POST /device_model_prices
  # POST /device_model_prices.xml
  def create
    @device_model_price = DeviceModelPrice.new(params[:device_model_price])

    respond_to do |format|
      if @device_model_price.save
        flash[:notice] = 'DeviceModelPrice was successfully created.'
        format.html { redirect_to :action => 'show', :id => @device_model_price }
        format.xml  { render :xml => @device_model_price, :status => :created, :location => @device_model_price }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @device_model_price.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /device_model_prices/1
  # PUT /device_model_prices/1.xml
  def update
    @device_model_price = DeviceModelPrice.find(params[:id])

    respond_to do |format|
      if @device_model_price.update_attributes(params[:device_model_price])
        flash[:notice] = 'DeviceModelPrice was successfully updated.'
        format.html { redirect_to :action => 'show', :id => @device_model_price }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @device_model_price.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /device_model_prices/1
  # DELETE /device_model_prices/1.xml
  def destroy
    @device_model_price = DeviceModelPrice.find(params[:id])
    @device_model_price.destroy

    respond_to do |format|
      format.html { redirect_to :action => 'index' }
      format.xml  { head :ok }
    end
  end
end