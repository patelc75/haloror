class EmergencyNumbersController < ApplicationController
  
  def index
    @groups = current_user.group_memberships
    if check_params_for_group      
      group_name = params[:group]
      @group = Group.find_by_name(group_name)
      @emergency_numbers = EmergencyNumber.find_all_by_group_id(@group.id)
    else
      @emergency_numbers = []
      @group = @groups[0] if @groups && @groups.size > 0
    end    
  end
  def new
    if check_params_for_group
      group_name = params[:group]
      @group = Group.find_by_name(group_name)
      @emergency_number = EmergencyNumber.new()
    else
      redirect_to :action => 'index'
    end
  end
  
  def create
    if check_params_for_group
      @emergency_number = EmergencyNumber.new(params[:emergency_number])
      group = Group.find_by_name(params[:group])
      @emergency_number.group_id = group.id
      @emergency_number.save!
      redirect_to :action => 'index', :group => params[:group]
    else
      redirect_to :action => 'index'
    end
  end
  
  private 
  def check_params_for_group
    return (!params[:group].blank? && params[:group] != 'Choose a Group')
  end
end