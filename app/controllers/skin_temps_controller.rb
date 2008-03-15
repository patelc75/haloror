class SkinTempsController < RestfulAuthController
  # GET /skin_temps
  # GET /skin_temps.xml
  def index
    @skin_temps = SkinTemp.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @skin_temps.to_xml }
    end
  end

  # GET /skin_temps/1
  # GET /skin_temps/1.xml
  def show
    @skin_temp = SkinTemp.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @skin_temp.to_xml }
    end
  end

  # GET /skin_temps/new
  def new
    @skin_temp = SkinTemp.new
  end

  # GET /skin_temps/1;edit
  def edit
    @skin_temp = SkinTemp.find(params[:id])
  end

  # POST /skin_temps
  # POST /skin_temps.xml
  def create
    @skin_temp = SkinTemp.new(params[:skin_temp])

    respond_to do |format|
      if @skin_temp.save
        flash[:notice] = 'SkinTemp was successfully created.'
        format.html { redirect_to skin_temp_url(@skin_temp) }
        format.xml  { head :created, :location => skin_temp_url(@skin_temp) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @skin_temp.errors.to_xml }
      end
    end
  end

  # PUT /skin_temps/1
  # PUT /skin_temps/1.xml
  def update
    @skin_temp = SkinTemp.find(params[:id])

    respond_to do |format|
      if @skin_temp.update_attributes(params[:skin_temp])
        flash[:notice] = 'SkinTemp was successfully updated.'
        format.html { redirect_to skin_temp_url(@skin_temp) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @skin_temp.errors.to_xml }
      end
    end
  end

  # DELETE /skin_temps/1
  # DELETE /skin_temps/1.xml
  def destroy
    @skin_temp = SkinTemp.find(params[:id])
    @skin_temp.destroy

    respond_to do |format|
      format.html { redirect_to skin_temps_url }
      format.xml  { head :ok }
    end
  end
end
