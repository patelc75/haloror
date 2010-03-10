class RmasController < ApplicationController

  def index
  	@groups = current_user.group_memberships

    cond = "1=1"
  	search = params[:search]
    # cond += " and user_id = #{search} or phone_number like '%#{search}%'" if search and !search.blank?
    # cond += " and group_id = #{params[:group][:id]}" if params[:group] and !params[:group][:id].blank?
    cond = ["rmas.user_id = ? OR rmas.serial_number = ? OR rmas.status = ?", search.to_i, search, search] \
      unless search.blank?
    @rmas = Rma.paginate  :page => params[:page], \
                          :order => 'created_at desc', :per_page => 20, :conditions => cond

    respond_to do |format|
      format.html
    end
  end

  def new
  	@rma = Rma.new
    @groups = current_user.group_memberships

    respond_to do |format|
      format.html
    end
  end

  def create
    @rma = Rma.new(params[:rma])
    @rma.created_by = current_user.id

    respond_to do |format|
      if @rma.save
        flash[:notice] = 'RMA was successfully saved.'
        format.html { redirect_to(:action => 'show', :id => @rma.id) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def edit
    @rma = Rma.find(params[:id])
    @groups = current_user.group_memberships
    
    respond_to do |format|
      format.html
    end
  end  
  
  def update
    @rma = Rma.find(params[:id])

    respond_to do |format|
      if @rma.update_attributes(params[:rma])
        flash[:notice] = 'RMA was successfully updated.'
        format.html { redirect_to(:action => 'show', :id => @rma.id) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit", :id => @rma.id }
        format.xml  { render :xml => @rma.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def show
  	@rma = Rma.find params[:id]
  end
  
  def destroy
    @rma = Rma.find(params[:id])
    @rma.destroy

    respond_to do |format|
      format.html { redirect_to(:action => 'index') }
      format.xml  { head :ok }
    end
  end
end
