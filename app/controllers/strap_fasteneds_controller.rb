class StrapFastenedsController < ApplicationController
  # GET /strap_fasteneds
  # GET /strap_fasteneds.xml
  def index
    @strap_fasteneds = StrapFastened.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @strap_fasteneds }
    end
  end

  # GET /strap_fasteneds/1
  # GET /strap_fasteneds/1.xml
  def show
    @strap_fastened = StrapFastened.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @strap_fastened }
    end
  end

  # GET /strap_fasteneds/new
  # GET /strap_fasteneds/new.xml
  def new
    @strap_fastened = StrapFastened.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @strap_fastened }
    end
  end

  # GET /strap_fasteneds/1/edit
  def edit
    @strap_fastened = StrapFastened.find(params[:id])
  end

  # POST /strap_fasteneds
  # POST /strap_fasteneds.xml
  def create
    @strap_fastened = StrapFastened.new(params[:strap_fastened])

    respond_to do |format|
      if @strap_fastened.save
        flash[:notice] = 'StrapFastened was successfully created.'
        format.html { redirect_to(@strap_fastened) }
        format.xml  { render :xml => @strap_fastened, :status => :created, :location => @strap_fastened }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @strap_fastened.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /strap_fasteneds/1
  # PUT /strap_fasteneds/1.xml
  def update
    @strap_fastened = StrapFastened.find(params[:id])

    respond_to do |format|
      if @strap_fastened.update_attributes(params[:strap_fastened])
        flash[:notice] = 'StrapFastened was successfully updated.'
        format.html { redirect_to(@strap_fastened) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @strap_fastened.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /strap_fasteneds/1
  # DELETE /strap_fasteneds/1.xml
  def destroy
    @strap_fastened = StrapFastened.find(params[:id])
    @strap_fastened.destroy

    respond_to do |format|
      format.html { redirect_to(strap_fasteneds_url) }
      format.xml  { head :ok }
    end
  end
end
