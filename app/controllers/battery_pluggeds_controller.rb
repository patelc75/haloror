class BatteryPluggedsController < ApplicationController
  # GET /battery_pluggeds
  # GET /battery_pluggeds.xml
  def index
    @battery_pluggeds = BatteryPlugged.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @battery_pluggeds }
    end
  end

  # GET /battery_pluggeds/1
  # GET /battery_pluggeds/1.xml
  def show
    @battery_plugged = BatteryPlugged.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @battery_plugged }
    end
  end

  # GET /battery_pluggeds/new
  # GET /battery_pluggeds/new.xml
  def new
    @battery_plugged = BatteryPlugged.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @battery_plugged }
    end
  end

  # GET /battery_pluggeds/1/edit
  def edit
    @battery_plugged = BatteryPlugged.find(params[:id])
  end

  # POST /battery_pluggeds
  # POST /battery_pluggeds.xml
  def create
    @battery_plugged = BatteryPlugged.new(params[:battery_plugged])

    respond_to do |format|
      if @battery_plugged.save
        flash[:notice] = 'BatteryPlugged was successfully created.'
        format.html { redirect_to(@battery_plugged) }
        format.xml  { render :xml => @battery_plugged, :status => :created, :location => @battery_plugged }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @battery_plugged.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /battery_pluggeds/1
  # PUT /battery_pluggeds/1.xml
  def update
    @battery_plugged = BatteryPlugged.find(params[:id])

    respond_to do |format|
      if @battery_plugged.update_attributes(params[:battery_plugged])
        flash[:notice] = 'BatteryPlugged was successfully updated.'
        format.html { redirect_to(@battery_plugged) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @battery_plugged.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /battery_pluggeds/1
  # DELETE /battery_pluggeds/1.xml
  def destroy
    @battery_plugged = BatteryPlugged.find(params[:id])
    @battery_plugged.destroy

    respond_to do |format|
      format.html { redirect_to(battery_pluggeds_url) }
      format.xml  { head :ok }
    end
  end
end
