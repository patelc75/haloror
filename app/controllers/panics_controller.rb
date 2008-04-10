class PanicsController < RestfulAuthController
  # # GET /panics
  #   # GET /panics.xml
  #   def index
  #     @panics = Panic.find(:all)
  # 
  #     respond_to do |format|
  #       format.html # index.rhtml
  #       format.xml  { render :xml => @panics.to_xml }
  #     end
  #   end
  # 
  #   # GET /panics/1
  #   # GET /panics/1.xml
  #   def show
  #     @panic = Panic.find(params[:id])
  # 
  #     respond_to do |format|
  #       format.html # show.rhtml
  #       format.xml  { render :xml => @panic.to_xml }
  #     end
  #   end
  # 
  #   # GET /panics/new
  #   def new
  #     @panic = Panic.new
  #   end
  # 
  #   # GET /panics/1;edit
  #   def edit
  #     @panic = Panic.find(params[:id])
  #   end
  # 
  #   # POST /panics
  #   # POST /panics.xml
  #   def create
  #     @panic = Panic.new(params[:panic])
  # 
  #   #email = CriticalMailer.panic_notification
  #   #put this in panics model 
  #   
  #     respond_to do |format|
  #       if @panic.save
  #         flash[:notice] = 'Panic was successfully created.'
  #         format.html { redirect_to panic_url(@panic) }
  #         format.xml  { head :created, :location => panic_url(@panic) }
  #       else
  #         format.html { render :action => "new" }
  #         format.xml  { render :xml => @panic.errors.to_xml }
  #       end
  #     end
  #   end
  # 
  #   # PUT /panics/1
  #   # PUT /panics/1.xml
  #   def update
  #     @panic = Panic.find(params[:id])
  # 
  #     respond_to do |format|
  #       if @panic.update_attributes(params[:panic])
  #         flash[:notice] = 'Panic was successfully updated.'
  #         format.html { redirect_to panic_url(@panic) }
  #         format.xml  { head :ok }
  #       else
  #         format.html { render :action => "edit" }
  #         format.xml  { render :xml => @panic.errors.to_xml }
  #       end
  #     end
  #   end
  # 
  #   # DELETE /panics/1
  #   # DELETE /panics/1.xml
  #   def destroy
  #     @panic = Panic.find(params[:id])
  #     @panic.destroy
  # 
  #     respond_to do |format|
  #       format.html { redirect_to panics_url }
  #       format.xml  { head :ok }
  #     end
  #   end
end
