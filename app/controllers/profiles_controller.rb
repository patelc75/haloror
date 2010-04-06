class ProfilesController < ApplicationController
  # GET /profiles
  # GET /profiles.xml
  def index
    @profiles = Profile.find(:all)
 
    #   @profiled = Profile.find(params[:id])

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @profiles.to_xml }
    end
  end

  # GET /profiles/1
  # GET /profiles/1.xml
  def show
    @profile = Profile.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @profile.to_xml }
    end
  end

  # GET /profiles/new
  def new
    @profile = Profile.new
  end

  # GET /profiles/1;edit
  def edit
    @profile = Profile.find(params[:id])
  end

  # POST /profiles
  # POST /profiles.xml
  def create
    @profile = Profile.new(params[:profile])

    respond_to do |format|
      if @profile.save
        flash[:notice] = 'Profile was successfully created.'
        format.html { redirect_to profile_url(@profile) }
        format.xml  { head :created, :location => profile_url(@profile) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @profile.errors.to_xml }
      end
    end
  end

  # PUT /profiles/1
  # PUT /profiles/1.xml
  def update
    @profile = Profile.find_by_user_id(params[:user_id])

    respond_to do |format|
      if @profile.update_attributes(params[:profile])
        flash[:notice] = 'Profile was successfully updated.'
        format.html { redirect_to profile_url(@profile) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @profile.errors.to_xml }
      end
    end
  end

  # DELETE /profiles/1
  # DELETE /profiles/1.xml
  def destroy
    @profile = Profile.find(params[:id])
    @profile.destroy

    respond_to do |format|
      format.html { redirect_to profiles_url }
      format.xml  { head :ok }
    end
  end

  def resend_mail
  	@roles_users_option = RolesUsersOption.find_by_roles_user_id(params[:roles_user_id])
  	User.resend_mail(params[:id],@roles_users_option.roles_user.role.authorizable_id)
  	redirect_to request.env['HTTP_REFERER']
  end

  def edit_caregiver_profile
    @profile = Profile.find(params[:id], :include => :user)
    @group_id = params[:group_id]
    @user = @profile.user
    if(!params[:roles_user_id].blank?)
      @roles_users_option = RolesUsersOption.find_by_roles_user_id(params[:roles_user_id])
    end
    session[:redirect_url] = request.env['HTTP_REFERER']
  end
  
  def new_caregiver_profile
	@removed_caregivers = []
	@senior = User.find params[:user_id]
    @senior.caregivers.each do |caregiver|
      if caregiver
        caregiver.roles_users.each do |roles_user|
          if roles_user.roles_users_option and roles_user.roles_users_option[:removed]
            @removed_caregivers << caregiver
          end
        end 
      end
    end
    get_caregivers(current_user)
    @max_position = User.get_max_caregiver_position(@senior)
    @user = User.new 
    @profile = Profile.new    	
  end
   
  def create_caregiver_profile
  	
  	@user = User.new(params[:user])
    @profile = Profile.new(params[:profile])
  
    	User.transaction do 
    		@user.email = params[:email]
    		@user.is_new_caregiver = true
    		@user[:is_caregiver] =  true
    		if @user.save
    			@user.activate #this call differentiates this method UsersController.populate_caregiver 
    			
    			@profile.user_id = @user.id
    			@profile[:is_new_caregiver] = true
    			if @profile.save!
    				patient = User.find(params[:patient_id].to_i)
    				role = @user.has_role 'caregiver', patient
    				caregiver = @user
    				@roles_user = patient.roles_user_by_caregiver(caregiver)
    				update_from_position(params[:position], @roles_user.role_id, caregiver.id)
    				if !role.nil?
    				  RolesUsersOption.create(:roles_user_id => @roles_user.id, :position => params[:position], :active => true,:relationship => params[:relationship],:is_keyholder => params[:key_holder][:is_keyholder])
    				end
    			else
    				#render :action => 'new_caregiver_profile',:user_id => current_user
    				raise "Invalid Profile"
    			end
    		else
    			#render :action => 'new_caregiver_profile',:user_id => current_user
    			 raise "Invalid User"
    		end
    	redirect_to :controller => 'call_list',:action => 'show',:id => params[:patient_id]
    		
		end
		
  rescue Exception => e
    RAILS_DEFAULT_LOGGER.warn("ERROR signing up, #{e}")
    render :action => 'new_caregiver_profile'
  
  
    #rescue Exception => e
    	#RAILS_DEFAULT_LOGGER.warn "#{e}"
    	#render :action => 'new_caregiver_profile',:user_id => current_user
=begin
    	@removed_caregivers = []   
    	current_user.caregivers.each do |caregiver|
    	  if caregiver
    	    caregiver.roles_users.each do |roles_user|
    	      if roles_user.roles_users_option and roles_user.roles_users_option[:removed]
    	        @removed_caregivers << caregiver
    	      end
    	    end 
    	  end
    	end
    	get_caregivers(current_user)
    	@max_position = @caregivers.size + 1
     	@user = User.new 
    	@profile = Profile.new  
=end
#		render :partial => '/profiles/new_caregiver_profile'


  end
  def update_from_position(position, roles_user_id, user_id)
    caregivers = RolesUsersOption.find(:all, :conditions => "position >= #{position} and roles_user_id = #{roles_user_id}")
    
    caregivers.each do |caregiver|
      caregiver.position+=1
      caregiver.save
    end
  end
  
  
  def update_caregiver_profile
    if request.post?
      sent = false
      user = User.find(params[:user_id])
      @profile = Profile.find(params[:id])
      @user = user
      @group_id = params[:group_id]
      #    raise params.inspect
      begin
        User.transaction do
          user.update_attribute('email', params[:email])
          if(!params[:roles_user_id].blank?)
            @roles_users_option = RolesUsersOption.find_by_roles_user_id(params[:roles_user_id])
            @roles_users_option.update_attributes!(params[:roles_users_option])
            @roles_users_option.relationship = params[:relationship]
            @roles_users_option.save!
          end

          if @profile.update_attributes!(params[:profile])
            if((current_user.is_super_admin? || current_user.is_admin_of_any?(user.group_memberships)) and user.is_halouser?)
              group = Group.find_by_name('safety_care')
              if(params[:opt_out_call_center].blank?)
                user.is_halouser_of group
              elsif(user.is_halouser_of? group)
                role = Role.find(:first, :conditions => "name = 'halouser' AND authorizable_type = 'Group' AND authorizable_id = #{group.id}")
                ru = RolesUser.find(:first, :conditions => "user_id = #{user.id} AND role_id = #{role.id}")
                RolesUser.delete(ru)
              end
            end
          end
          @alert_message = true
          render :action => 'edit_caregiver_profile'
        end
      rescue Exception => e
        render :action => 'edit_caregiver_profile'
      end
    else
      redirect_to :action => "edit_caregiver_profile", :id => current_user.profile.id, :user_id => current_user.id
    end
  end
  
  def change_password_init
    @user = User.find(params[:user_id])
    #render :partial => 'change_password_init'
  end
  def change_password
    user_hash = params[:user]
    user = User.find(user_hash[:id])
    unless current_user.is_super_admin? || current_user.is_admin_of_any?(user.group_memberships)
      if user == current_user || current_user.is_super_admin? || current_user.is_admin_of_any?(user.group_memberships)
        if User.authenticate(user.login, user_hash[:current_password])
          if user_hash[:password] == user_hash[:password_confirmation]
            if user_hash[:password].length >= 4
              user.password = user_hash[:password]
              user.password_confirmation = user_hash[:password_confirmation]
              user.save!
            else
              @message = "Password must be at least 4 characters"
            end
          else
            @message = "New Password must equal Confirm Password"
          end          
        else  
          @message = "Old Password must equal Current Password"
        end
      end
    else
      if user_hash[:password] == user_hash[:password_confirmation]
        if user_hash[:password].length >= 4
          UtilityHelper.change_password_by_user_id(user.id, user_hash[:password])
        else
          @message = "Password must be at least 4 characters"
        end
      else
        @message = "New Password must equal Confirm Password"
      end
    end
    if @message.nil?
      @success_message = true
      #send email
      CriticalMailer.deliver_password_confirmation(user)
    end
    @user = user
    if request.xhr?
    	render :partial => 'change_password_init'
    else
    	render :action => 'change_password_init',:user_id => params[:user][:id]
    end
  end
end