class VitalsController < RestfulAuthController
  # GET /vitals
  # GET /vitals.xml
  def index
    @vitals = Vital.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @vitals.to_xml }
    end
  end

  # GET /vitals/1
  # GET /vitals/1.xml
  def show
    @vital = Vital.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @vital.to_xml }
    end
  end

  # GET /vitals/new
  def new
    @vital = Vital.new
  end

  # GET /vitals/1;edit
  def edit
    @vital = Vital.find(params[:id])
  end

  # POST /vitals
  # POST /vitals.xml
  def create
    @vital = Vital.new(params[:vital])

    respond_to do |format|
      if @vital.save
        flash[:notice] = 'Vital was successfully created.'
        format.html { redirect_to vital_url(@vital) }
        format.xml  { head :created, :location => vital_url(@vital) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @vital.errors.to_xml }
      end
    end
  end

  # PUT /vitals/1
  # PUT /vitals/1.xml
  def update
    @vital = Vital.find(params[:id])

    respond_to do |format|
      if @vital.update_attributes(params[:vital])
        flash[:notice] = 'Vital was successfully updated.'
        format.html { redirect_to vital_url(@vital) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @vital.errors.to_xml }
      end
    end
  end

  # DELETE /vitals/1
  # DELETE /vitals/1.xml
  def destroy
    @vital = Vital.find(params[:id])
    @vital.destroy

    respond_to do |format|
      format.html { redirect_to vitals_url }
      format.xml  { head :ok }
    end
  end
end
