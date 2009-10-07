class RecurringChargesController < ApplicationController
 def index
	@recurring_charges = RecurringCharge.find(:all)
  end

  def new
  	group_array	
  end
  
  def create
  	
  @recurring_charge = RecurringCharge.new(params[:recurring_charges])
  @recurring_charge.group_id = params[:group]
  	if !@recurring_charge.save
		group_array
  		render :action => 'new'
  	else
  		redirect_to :action => 'index'
  	end
  end
  
  def edit
  	group_array
  	@recurring_charge = RecurringCharge.find(params[:id])
  end

  def update
  	@recurring_charge = RecurringCharge.find(params[:id])
  	@group = Group.find_by_name(params[:group])
  	if !@recurring_charge.update_attributes(:charge => params[:recurring_charges][:charge],:group_id => @group.id )
  		group_array
  		render :action => 'edit'
  	else
  		redirect_to :action => 'index'
  	end
  	
  end
  
  def destroy
  	@recurring_charge = RecurringCharge.find(params[:id])
  	@recurring_charge.destroy
  	redirect_to :action => 'index'
  end

  private
  
  def group_array
  	@groups = []
    if current_user.is_super_admin?
      @groups = Group.find(:all)
    else
      @groups = current_user.group_memberships
    end
  end
   
end
