class RmaItemsController < ApplicationController
  def index
    @rma = Rma.find_by_id(params[:rma_id])
    @rma_items = @rma.rma_items
    
    respond_to do |format|
      format.html
    end
  end
  
  def new
    @rma = Rma.find_by_id(params[:rma_id])
    @rma_item = @rma.rma_items.build
    @groups = current_user.group_memberships

    respond_to do |format|
      format.html
    end
  end
  
  def create
    @rma_item = RmaItem.new(params[:rma_item])
    # @rma = Rma.find_by_id(params[:rma_item][:rma_id].to_i)
    
    respond_to do |format|
      if @rma_item.save
        flash[:notice] = 'RMA Item was successfully saved.'
        format.html { redirect_to( :controller => "rmas", :action => 'show', :id => @rma_item.rma_id) }
      else
        format.html { render :action => "new" }
      end
    end
  end
  
  def edit
    @rma_item = RmaItem.find_by_id(params[:id])
    @rma = Rma.find_by_id(params[:rma_id])
    @groups = current_user.group_memberships
        
    respond_to do |format|
      format.html
    end
  end  
  
  def update
    @rma_item = RmaItem.find(params[:id])
    # @rma = Rma.find_by_id(params[:rma_item][:rma_id].to_i)

    respond_to do |format|
      if @rma_item.update_attributes(params[:rma_item])
        flash[:notice] = 'RMA Item was successfully updated.'
        format.html { redirect_to( :controller => "rmas", :action => 'show', :id => @rma_item.rma_id) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit", :id => @rma_item.id }
        format.xml  { render :xml => @rma_item.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def show
  	@rma_item = RmaItem.find params[:id]
  	@rma = Rma.find_by_id(@rma_item.rma_id)
  end
  
  def destroy
    @rma_item = RmaItem.find(params[:id])
    @rma = Rma.find_by_id(@rma_item.rma_id)
    @rma_item.destroy

    respond_to do |format|
      format.html { redirect_to( :controller => "rmas", :action => 'show', :id => @rma.id) }
      format.xml  { head :ok }
    end
  end
  
end
