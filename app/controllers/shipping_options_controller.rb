class ShippingOptionsController < ApplicationController
  # GET /shipping_options
  # GET /shipping_options.xml
  def index
    @shipping_options = ShippingOption.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @shipping_options }
    end
  end

  # GET /shipping_options/1
  # GET /shipping_options/1.xml
  def show
    @shipping_option = ShippingOption.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @shipping_option }
    end
  end

  # GET /shipping_options/new
  # GET /shipping_options/new.xml
  def new
    @shipping_option = ShippingOption.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @shipping_option }
    end
  end

  # GET /shipping_options/1/edit
  def edit
    @shipping_option = ShippingOption.find(params[:id])
  end

  # POST /shipping_options
  # POST /shipping_options.xml
  def create
    @shipping_option = ShippingOption.new(params[:shipping_option])

    respond_to do |format|
      if @shipping_option.save
        flash[:notice] = 'ShippingOption was successfully created.'
        format.html { redirect_to :controller => 'shipping_options' }
        format.xml  { render :xml => @shipping_option, :status => :created, :location => @shipping_option }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @shipping_option.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /shipping_options/1
  # PUT /shipping_options/1.xml
  def update
    @shipping_option = ShippingOption.find(params[:id])

    respond_to do |format|
      if @shipping_option.update_attributes(params[:shipping_option])
        flash[:notice] = 'ShippingOption was successfully updated.'
        format.html { redirect_to :controller => 'shipping_options' }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @shipping_option.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /shipping_options/1
  # DELETE /shipping_options/1.xml
  def destroy
    @shipping_option = ShippingOption.find(params[:id])
    @shipping_option.destroy

    respond_to do |format|
      format.html { redirect_to :controller => 'shipping_options' }
      format.xml  { head :ok }
    end
  end
end
