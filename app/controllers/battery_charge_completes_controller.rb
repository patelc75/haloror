class BatteryChargeCompletesController < ApplicationController
  # GET /battery_charge_completes
  # GET /battery_charge_completes.xml
  def index
    @battery_charge_completes = BatteryChargeComplete.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @battery_charge_completes }
    end
  end

  # GET /battery_charge_completes/1
  # GET /battery_charge_completes/1.xml
  def show
    @battery_charge_complete = BatteryChargeComplete.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @battery_charge_complete }
    end
  end

  # GET /battery_charge_completes/new
  # GET /battery_charge_completes/new.xml
  def new
    @battery_charge_complete = BatteryChargeComplete.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @battery_charge_complete }
    end
  end

  # GET /battery_charge_completes/1/edit
  def edit
    @battery_charge_complete = BatteryChargeComplete.find(params[:id])
  end

  # POST /battery_charge_completes
  # POST /battery_charge_completes.xml
  def create
    @battery_charge_complete = BatteryChargeComplete.new(params[:battery_charge_complete])

    respond_to do |format|
      if @battery_charge_complete.save
        flash[:notice] = 'BatteryChargeComplete was successfully created.'
        format.html { redirect_to(@battery_charge_complete) }
        format.xml  { render :xml => @battery_charge_complete, :status => :created, :location => @battery_charge_complete }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @battery_charge_complete.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /battery_charge_completes/1
  # PUT /battery_charge_completes/1.xml
  def update
    @battery_charge_complete = BatteryChargeComplete.find(params[:id])

    respond_to do |format|
      if @battery_charge_complete.update_attributes(params[:battery_charge_complete])
        flash[:notice] = 'BatteryChargeComplete was successfully updated.'
        format.html { redirect_to(@battery_charge_complete) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @battery_charge_complete.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /battery_charge_completes/1
  # DELETE /battery_charge_completes/1.xml
  def destroy
    @battery_charge_complete = BatteryChargeComplete.find(params[:id])
    @battery_charge_complete.destroy

    respond_to do |format|
      format.html { redirect_to(battery_charge_completes_url) }
      format.xml  { head :ok }
    end
  end
end
