class ReportingController < ApplicationController
  def users
    @users = User.find(:all)
  end
  
  def devices
    @devices = Device.find(:all)
  end
  
  def sort_user_table
    #order = "#{params[:col]} asc"
    
    #users = User.find(:all, :order => order)
    users = User.find(:all)
    sortby = 'id'
    
    render :partial => 'user_table', :locals => {:users => users, :sortby => params[:col], :reverse => false}
  end
  
  def search_user_table
    users = User.find(:all, :conditions => "login like '%#{params[:query]}%' or first_name like '%#{params[:query]}%' or last_name like '%#{params[:query]}%'",:include => [ :profile ])
        
    render :partial => 'user_table', :locals => {:users => users, :sortby => 'id', :reverse => false}
  end
end
