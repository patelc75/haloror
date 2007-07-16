class RawDataFilesController < ApplicationController
  # GET /raw_data_files
  # GET /raw_data_files.xml
  def index
    @raw_data_files = RawDataFile.find(:all, :conditions => {:parent_id => nil}, :order => 'created_at DESC')

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @raw_data_files.to_xml }
    end
  end

  # GET /raw_data_files/1
  # GET /raw_data_files/1.xml
  def show
    @raw_data_file = RawDataFile.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @raw_data_file.to_xml }
    end
  end

  # GET /raw_data_files/new
  def new
    @raw_data_file = RawDataFile.new
  end

  # GET /raw_data_files/1;edit
  def edit
    @raw_data_file = RawDataFile.find(params[:id])
  end

  # POST /raw_data_files
  # POST /raw_data_files.xml
  def create
    #logger.debug{ "create params #{params} \n\n" }
    @raw_data_file = RawDataFile.new(params[:raw_data_file])
	
    respond_to do |format|
      if @raw_data_file.save
        flash[:notice] = 'RawDataFile was successfully created.'
        format.html { redirect_to raw_data_file_url(@raw_data_file) }
        format.xml  { head :created, :location => raw_data_file_url(@raw_data_file) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @raw_data_file.errors.to_xml }
      end
    end
  end

  # PUT /raw_data_files/1
  # PUT /raw_data_files/1.xml
  def update
    @raw_data_file = RawDataFile.find(params[:id])

    respond_to do |format|
      if @raw_data_file.update_attributes(params[:raw_data_file])
        flash[:notice] = 'RawDataFile was successfully updated.'
        format.html { redirect_to raw_data_file_url(@raw_data_file) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @raw_data_file.errors.to_xml }
      end
    end
  end

  # DELETE /raw_data_files/1
  # DELETE /raw_data_files/1.xml
  def destroy
    @raw_data_file = RawDataFile.find(params[:id])
    @raw_data_file.destroy

    respond_to do |format|
      format.html { redirect_to raw_data_files_url }
      format.xml  { head :ok }
    end
  end
  
  def download
    @raw_data_file = RawDataFile.find(params[:id])
    send_file("#{RAILS_ROOT}/public"+@raw_data_file.public_filename, 
      :disposition => 'attachment',
      :encoding => 'utf8', 
      :type => @raw_data_file.content_type,
      :filename => URI.encode(@raw_data_file.filename)) 
  end
end
