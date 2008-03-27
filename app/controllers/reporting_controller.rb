class ReportingController < ApplicationController
  def index
    @users = User.find(:all)
  end
  
  def sort_user_table
    order = "#{params[:col]} asc"
    
    users = User.find(:all, :order => order)
    
    render :partial => 'user_table', :locals => {:users => users}
  end
end
