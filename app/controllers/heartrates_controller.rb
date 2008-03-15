# Generated by scaffold_resource generator.
# This controller's primary purpose is to allow REST access to
# the Heartrate model (database)

class HeartratesController < RestfulAuthController
  # GET /heartrates
  # GET /heartrates.xml
  def index
    @heartrates = Heartrate.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @heartrates.to_xml }
    end
  end

  # GET /heartrates/1
  # GET /heartrates/1.xml
  def show
    @heartrate = Heartrate.find(params[:id])
    #debugger if ENV['RAILS_ENV'] == 'development'
    respond_to do |format|
      #format.html # show.rhtml
      format.xml  { render :xml => @heartrate.to_xml }
    end
  end

  # GET /heartrates/new
  def new
    @heartrate = Heartrate.new
  end

  # GET /heartrates/1;edit
  def edit
    @heartrate = Heartrate.find(params[:id])
  end

  # POST /heartrates
  # POST /heartrates.xml
  def create
    @heartrate = Heartrate.new(params[:heartrate])
    	
    #debugger if ENV['RAILS_ENV'] == 'development'		
    #breakpoint "Let's have a closer look at @heartrate" 
    
    #chirag: take the 'format' array returned from respond_to method and iterate over it
    respond_to do |format| 
      if @heartrate.save
        flash[:notice] = 'Heartrate was successfully created.'
        #format.html { redirect_to heartrate_url(@heartrate) }
        format.xml  { head :created, :location => heartrate_url(@heartrate) }
      else
        #format.html { render :action => "new" }
        format.xml  { render :xml => @heartrate.errors.to_xml }
      end
    end
  end

  # PUT /heartrates/1
  # PUT /heartrates/1.xml
  def update
    @heartrate = Heartrate.find(params[:id])

    respond_to do |format|
      if @heartrate.update_attributes(params[:heartrate])
        flash[:notice] = 'Heartrate was successfully updated.'
        format.html { redirect_to heartrate_url(@heartrate) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @heartrate.errors.to_xml }
      end
    end
  end

  # DELETE /heartrates/1
  # DELETE /heartrates/1.xml
  def destroy
    @heartrate = Heartrate.find(params[:id])
    @heartrate.destroy

    respond_to do |format|
      format.html { redirect_to heartrates_url }
      format.xml  { head :ok }
    end
  end
  
  def dummy
  end
end
