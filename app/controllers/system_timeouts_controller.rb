class SystemTimeoutsController < ApplicationController
  #list current system timeouts
  def index
    @system_timeouts = SystemTimeout.find(:all)
  end
  
  #edit a system timeout 
  #/system_timeouts/edit/:id
  def edit
    @system_timeout = SystemTimeout.find(params[:id])
  end
  
  #update a system timeout
  #/system_timeouts/update/:id
  def update
    @system_timeout = SystemTimeout.find(params[:id])
    @system_timeout.update_attributes(params[:system_timeout])
    if @system_timeout.save
      flash[:notice] = 'System Timeout saved.'
      redirect_to :action => 'index'
    else
      flash[:warning] = 'System Timeout not saved.'
      render :action => 'edit'
    end
  end
end