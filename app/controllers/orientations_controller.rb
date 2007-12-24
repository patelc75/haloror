class OrientationsController < ApplicationController
  # GET /orientations
  # GET /orientations.xml
  def index
    @orientations = Orientation.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @orientations.to_xml }
    end
  end

  # GET /orientations/1
  # GET /orientations/1.xml
  def show
    @orientation = Orientation.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @orientation.to_xml }
    end
  end

  # GET /orientations/new
  def new
    @orientation = Orientation.new
  end

  # GET /orientations/1;edit
  def edit
    @orientation = Orientation.find(params[:id])
  end

  # POST /orientations
  # POST /orientations.xml
  def create
    @orientation = Orientation.new(params[:orientation])

    respond_to do |format|
      if @orientation.save
        flash[:notice] = 'Orientation was successfully created.'
        format.html { redirect_to orientation_url(@orientation) }
        format.xml  { head :created, :location => orientation_url(@orientation) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @orientation.errors.to_xml }
      end
    end
  end

  # PUT /orientations/1
  # PUT /orientations/1.xml
  def update
    @orientation = Orientation.find(params[:id])

    respond_to do |format|
      if @orientation.update_attributes(params[:orientation])
        flash[:notice] = 'Orientation was successfully updated.'
        format.html { redirect_to orientation_url(@orientation) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @orientation.errors.to_xml }
      end
    end
  end

  # DELETE /orientations/1
  # DELETE /orientations/1.xml
  def destroy
    @orientation = Orientation.find(params[:id])
    @orientation.destroy

    respond_to do |format|
      format.html { redirect_to orientations_url }
      format.xml  { head :ok }
    end
  end
end
