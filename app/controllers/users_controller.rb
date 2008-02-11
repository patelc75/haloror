class UsersController < ApplicationController
  # render new.rhtml
  def new
	  #render :layout => false
  end

  def create
    @user = User.new(params[:user])
    @user.save!
    Profile.create(:user_id => @user.id)
    self.current_user = @user
    #redirect_back_or_default('/')
    #flash[:notice] = "Thanks for signing up!"
	#render :nothing => true
  rescue ActiveRecord::RecordInvalid
    render :action => 'new'
  end

  def activate
    self.current_user = User.find_by_activation_code(params[:activation_code])
    if logged_in? && !current_user.activated?
      current_user.activate
      #flash[:notice] = "Signup complete!"
    end
    #redirect_back_or_default('/')
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
    @user = User.find(params[:id])
    render :layout => false
  end  
  
  def ajax_edit
    @user = User.find(params[:id])
    render :layout => false
    end
  
  def redir_to_edit
    redirect_to '/users/'+params[:id]+';edit/'
  end
  
  def new_caregiver
    # get removed caregivers 
    
    @removed_caregivers = []
    
    current_user.has_caregivers.each do |caregiver|
      if caregiver.roles_users_option.removed
        @removed_caregivers.push(caregiver)
      end
    end
    
    render :layout => false
  end
  
  def create_caregiver
    user = User.new(params[:user])
    user.save!
    profile = Profile.create(:user_id => user.id, :email => user.email)
    #self.current_user = @user
    
    role = user.has_role 'caregiver', current_user
    
    #@user = User.find(user.id)
    @role = user.roles_user
    
    RolesUsersOption.create(:role_id => @role.role_id, :user_id => user.id)
    
    redirect_to :controller => 'profiles', :action => 'edit_caregiver_profile', :id => profile.id
  rescue ActiveRecord::RecordInvalid
    render :partial => 'caregiver_form'
  end
  
  def destroy_caregiver
    #Role.delete(params[:id])
    #RolesUser.delete_all "role_id = #{params[:id]}"
    
    RolesUsersOption.update(params[:id], {:removed => 1})
    
    render :layout =>false
  end
  
  def restore_caregiver_role
    RolesUsersOption.update(params[:id], {:removed => 0})
    
    refresh_caregivers
  end
end