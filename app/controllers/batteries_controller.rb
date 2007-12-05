class BatteriesController < ApplicationController
  # GET /batteries
  # GET /batteries.xml
  def index
    @batteries = Battery.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @batteries.to_xml }
    end
  end

  # GET /batteries/1
  # GET /batteries/1.xml
  def show
    @battery = Battery.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @battery.to_xml }
    end
  end

  # GET /batteries/new
  def new
    @battery = Battery.new
  end

  # GET /batteries/1;edit
  def edit
    @battery = Battery.find(params[:id])
  end

  # POST /batteries
  # POST /batteries.xml
  def create
    @battery = Battery.new(params[:battery])

    respond_to do |format|
      if @battery.save
        flash[:notice] = 'Battery was successfully created.'
        format.html { redirect_to battery_url(@battery) }
        format.xml  { head :created, :location => battery_url(@battery) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @battery.errors.to_xml }
      end
    end
  end

  # PUT /batteries/1
  # PUT /batteries/1.xml
  def update
    @battery = Battery.find(params[:id])

    respond_to do |format|
      if @battery.update_attributes(params[:battery])
        flash[:notice] = 'Battery was successfully updated.'
        format.html { redirect_to battery_url(@battery) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @battery.errors.to_xml }
      end
    end
  end

  # DELETE /batteries/1
  # DELETE /batteries/1.xml
  def destroy
    @battery = Battery.find(params[:id])
    @battery.destroy

    respond_to do |format|
      format.html { redirect_to batteries_url }
      format.xml  { head :ok }
    end
  end
end
