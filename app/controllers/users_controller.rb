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
  
  def update
    @user = User.find(params[:id])
    respond_to do |format|
      if @user.update_attributes!(params[:user])
		puts "look closer"
	
	    flash[:notice] = 'User was successfully updated.'
        format.html { redirect_to user_url(@user) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors.to_xml }
      end
	end
  end
  
  def edit
    @call_order = User.find(params[:id])
    render :layout => false
  end
  
  def redir_to_edit
    redirect_to_url '/users/'+params[:id]+';edit/'
  end
end