class BatteryUnpluggedsController < ApplicationController
  # GET /battery_unpluggeds
  # GET /battery_unpluggeds.xml
  def index
    @battery_unpluggeds = BatteryUnplugged.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @battery_unpluggeds }
    end
  end

  # GET /battery_unpluggeds/1
  # GET /battery_unpluggeds/1.xml
  def show
    @battery_unplugged = BatteryUnplugged.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @battery_unplugged }
    end
  end

  # GET /battery_unpluggeds/new
  # GET /battery_unpluggeds/new.xml
  def new
    @battery_unplugged = BatteryUnplugged.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @battery_unplugged }
    end
  end

  # GET /battery_unpluggeds/1/edit
  def edit
    @battery_unplugged = BatteryUnplugged.find(params[:id])
  end

  # POST /battery_unpluggeds
  # POST /battery_unpluggeds.xml
  def create
    @battery_unplugged = BatteryUnplugged.new(params[:battery_unplugged])

    respond_to do |format|
      if @battery_unplugged.save
        flash[:notice] = 'BatteryUnplugged was successfully created.'
        format.html { redirect_to(@battery_unplugged) }
        format.xml  { render :xml => @battery_unplugged, :status => :created, :location => @battery_unplugged }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @battery_unplugged.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /battery_unpluggeds/1
  # PUT /battery_unpluggeds/1.xml
  def update
    @battery_unplugged = BatteryUnplugged.find(params[:id])

    respond_to do |format|
      if @battery_unplugged.update_attributes(params[:battery_unplugged])
        flash[:notice] = 'BatteryUnplugged was successfully updated.'
        format.html { redirect_to(@battery_unplugged) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @battery_unplugged.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /battery_unpluggeds/1
  # DELETE /battery_unpluggeds/1.xml
  def destroy
    @battery_unplugged = BatteryUnplugged.find(params[:id])
    @battery_unplugged.destroy

    respond_to do |format|
      format.html { redirect_to(battery_unpluggeds_url) }
      format.xml  { head :ok }
    end
  end
end
