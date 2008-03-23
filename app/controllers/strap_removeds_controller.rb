class StrapRemovedsController < ApplicationController
  # GET /strap_removeds
  # GET /strap_removeds.xml
  def index
    @strap_removeds = StrapRemoved.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @strap_removeds }
    end
  end

  # GET /strap_removeds/1
  # GET /strap_removeds/1.xml
  def show
    @strap_removed = StrapRemoved.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @strap_removed }
    end
  end

  # GET /strap_removeds/new
  # GET /strap_removeds/new.xml
  def new
    @strap_removed = StrapRemoved.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @strap_removed }
    end
  end

  # GET /strap_removeds/1/edit
  def edit
    @strap_removed = StrapRemoved.find(params[:id])
  end

  # POST /strap_removeds
  # POST /strap_removeds.xml
  def create
    @strap_removed = StrapRemoved.new(params[:strap_removed])

    respond_to do |format|
      if @strap_removed.save
        flash[:notice] = 'StrapRemoved was successfully created.'
        format.html { redirect_to(@strap_removed) }
        format.xml  { render :xml => @strap_removed, :status => :created, :location => @strap_removed }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @strap_removed.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /strap_removeds/1
  # PUT /strap_removeds/1.xml
  def update
    @strap_removed = StrapRemoved.find(params[:id])

    respond_to do |format|
      if @strap_removed.update_attributes(params[:strap_removed])
        flash[:notice] = 'StrapRemoved was successfully updated.'
        format.html { redirect_to(@strap_removed) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @strap_removed.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /strap_removeds/1
  # DELETE /strap_removeds/1.xml
  def destroy
    @strap_removed = StrapRemoved.find(params[:id])
    @strap_removed.destroy

    respond_to do |format|
      format.html { redirect_to(strap_removeds_url) }
      format.xml  { head :ok }
    end
  end
end
