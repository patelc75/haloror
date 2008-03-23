class BatteryCriticalsController < ApplicationController
  # GET /battery_criticals
  # GET /battery_criticals.xml
  def index
    @battery_criticals = BatteryCritical.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @battery_criticals }
    end
  end

  # GET /battery_criticals/1
  # GET /battery_criticals/1.xml
  def show
    @battery_critical = BatteryCritical.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @battery_critical }
    end
  end

  # GET /battery_criticals/new
  # GET /battery_criticals/new.xml
  def new
    @battery_critical = BatteryCritical.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @battery_critical }
    end
  end

  # GET /battery_criticals/1/edit
  def edit
    @battery_critical = BatteryCritical.find(params[:id])
  end

  # POST /battery_criticals
  # POST /battery_criticals.xml
  def create
    @battery_critical = BatteryCritical.new(params[:battery_critical])

    respond_to do |format|
      if @battery_critical.save
        flash[:notice] = 'BatteryCritical was successfully created.'
        format.html { redirect_to(@battery_critical) }
        format.xml  { render :xml => @battery_critical, :status => :created, :location => @battery_critical }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @battery_critical.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /battery_criticals/1
  # PUT /battery_criticals/1.xml
  def update
    @battery_critical = BatteryCritical.find(params[:id])

    respond_to do |format|
      if @battery_critical.update_attributes(params[:battery_critical])
        flash[:notice] = 'BatteryCritical was successfully updated.'
        format.html { redirect_to(@battery_critical) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @battery_critical.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /battery_criticals/1
  # DELETE /battery_criticals/1.xml
  def destroy
    @battery_critical = BatteryCritical.find(params[:id])
    @battery_critical.destroy

    respond_to do |format|
      format.html { redirect_to(battery_criticals_url) }
      format.xml  { head :ok }
    end
  end
end
