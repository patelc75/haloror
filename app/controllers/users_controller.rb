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
    
    @max_position = get_max_caregiver_position
    
    @password = random_password
    
    render :layout => false
  end
  
  def create_caregiver
    @user = User.new(params[:user])
    @user.save!
    
    profile = Profile.create(:user_id => @user.id, :email => @user.email)
    
    role = @user.has_role 'caregiver', current_user
    @role = @user.roles_user
    
    update_from_position(params[:position], @role.role_id, @user.id)
    
    RolesUsersOption.create(:role_id => @role.role_id, :user_id => @user.id, :position => params[:position], :active => 1)
    
    redirect_to :controller => 'profiles', :action => 'edit_caregiver_profile', :id => profile.id
  rescue ActiveRecord::RecordInvalid
    @max_position = get_max_caregiver_position
    render :partial => 'caregiver_form'
  end
  
  def destroy_caregiver
    RolesUsersOption.update(params[:id], {:removed => 1})
    
    render :layout =>false
  end
  
  def restore_caregiver_role
    RolesUsersOption.update(params[:id], {:removed => 0})
    
    refresh_caregivers
  end
  
  def get_max_caregiver_position
    get_caregivers
    @caregivers.size + 1
  end
  
  def update_from_position(position, role_id, user_id)
    caregivers = RolesUsersOption.find(:all, "position >= #{position} and role_id = #{role_id} and user_id = #{user_id}")
    
    caregivers.each do |caregiver|
      caregiver.position+=1
      caregiver.save
    end
  end
  
  def random_password
    Digest::SHA1.hexdigest("--#{Time.now.to_s}--")[0,6]
  end
end