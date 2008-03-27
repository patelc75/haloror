class ReportingController < ApplicationController
  def users
    @users = User.find(:all)
  end
  
  def devices
    @devices = Device.find(:all)
  end
  
  def sort_user_table
    order = "#{params[:col]} asc"
    
    users = User.find(:all, :order => order)
    
    render :partial => 'user_table', :locals => {:users => users}
  end
end
