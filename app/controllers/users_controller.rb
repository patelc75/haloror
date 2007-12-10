class UsersController < ApplicationController

  # render new.rhtml
  def new
	  #render :layout => false
  end

  def create
    @user = User.new(params[:user])
    @user.save!
    self.current_user = @user
    #redirect_back_or_default('/')
    flash[:notice] = "Thanks for signing up!"
	render :nothing => true
  rescue ActiveRecord::RecordInvalid
    render :action => 'new', :layout => false
  end

  def activate
    self.current_user = User.find_by_activation_code(params[:activation_code])
    if logged_in? && !current_user.activated?
      current_user.activate
      flash[:notice] = "Signup complete!"
    end
    redirect_back_or_default('/')
  end
end
