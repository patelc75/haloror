class FallsController < RestfulAuthController
  # GET /falls
  # GET /falls.xml
  def index
    @falls = Fall.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @falls.to_xml }
    end
  end

  # GET /falls/1
  # GET /falls/1.xml
  def show
    @fall = Fall.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @fall.to_xml }
    end
  end

  # GET /falls/new
  def new
    @fall = Fall.new
  end

  # GET /falls/1;edit
  def edit
    @fall = Fall.find(params[:id])
  end

  # POST /falls
  # POST /falls.xml
  def create
    @fall = Fall.new(params[:fall])

    respond_to do |format|
      if @fall.save
        flash[:notice] = 'Fall was successfully created.'
        format.html { redirect_to fall_url(@fall) }
        format.xml  { head :created, :location => fall_url(@fall) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @fall.errors.to_xml }
      end
    end
  end

  # PUT /falls/1
  # PUT /falls/1.xml
  def update
    @fall = Fall.find(params[:id])

    respond_to do |format|
      if @fall.update_attributes(params[:fall])
        flash[:notice] = 'Fall was successfully updated.'
        format.html { redirect_to fall_url(@fall) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @fall.errors.to_xml }
      end
    end
  end

  # DELETE /falls/1
  # DELETE /falls/1.xml
  def destroy
    @fall = Fall.find(params[:id])
    @fall.destroy

    respond_to do |format|
      format.html { redirect_to falls_url }
      format.xml  { head :ok }
    end
  end
end
