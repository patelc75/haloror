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
    @senior = User.find(params[:user_id]) # additional parameter passed for correct logic
    if(!params[:roles_user_id].blank?)
      @roles_users_option = RolesUsersOption.find_by_roles_user_id(params[:roles_user_id])
    end
    session[:redirect_url] = request.env['HTTP_REFERER']
  end
  
  # = Error when adding a caregiver without email
  # https://redmine.corp.halomonitor.com/issues/2890#note-16
  # == we may reach here by "add new caregiver with no email"
  # * email address is optional here
  # * user model has a validation on email address
  # == solution
  # * user the new user intake object oriented code
  # * manually make changes to override validation for caregiver record
  def new_caregiver_profile
    @removed_caregivers = []
    @senior = User.find params[:user_id] # additional parameters passed for correct logic
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
    @max_position = @senior.next_caregiver_position # User.get_max_caregiver_position(@senior)
    @profile = Profile.new
    @user = User.new(:need_validation => false, :profile => @profile)
  end
   
  # 
  #  Sat Dec  4 01:40:54 IST 2010, ramonrails
  #   * TODO: DRY this up
  def create_caregiver_profile
    @user = User.new(params[:user])
    @profile = Profile.new(params[:profile])
    @user.profile = @profile
    @senior = User.find(params[:patient_id].to_i) # senior variable is used in view

    User.transaction do 
      @user.email = params[:email]
      @user.is_new_caregiver = true
      @user[:is_caregiver] =  true
      @user.skip_validation = true # skip validation, just save user data
      # 
      #  Wed Nov 24 03:31:20 IST 2010, ramonrails
      #   * caregiver role is lazy load now
      #   * this is required to set the role and send emails
      @user.lazy_roles[:caregiver] = @senior

      if @user.save
        # @user
        @user.activate #this call differentiates this method UsersController.populate_caregiver 
        # 
        #  Tue Dec 21 01:17:33 IST 2010, ramonrails
        #   * 
        #   * Make the caregiver "active for senior" when created from caregivers list
        # @user.options_for_senior( @senior, {:active => true}) # the latter syntax also works equally
        @user.options_attribute_for_senior( @senior, :active, true) # the former syntax also works equally
        
        @profile.user_id = @user.id
        @profile[:is_new_caregiver] = true
        if @profile.save!
          patient = User.find(params[:patient_id].to_i)
          # 
          #  Sat Dec  4 01:41:51 IST 2010, ramonrails
          #   * use the easier and better method
          @user.is_caregiver_for( patient) # create the role if not already exists
          @user.options_for_senior( patient, { :position => params[:position] })
          # OBSOLETE: old technoque
          #
          # role = @user.has_role 'caregiver', patient
          # caregiver = @user
          # @roles_user = patient.roles_user_by_caregiver(caregiver)
          # update_from_position(params[:position], @roles_user.role_id, caregiver.id) unless @roles_user.blank?
          # unless role.blank? || @roles_user.blank?
          #   # a few attributes were removed from the form. this was causing Exception and user data not saved
          #   RolesUsersOption.create(:roles_user_id => @roles_user.id, :position => params[:position], :active => true) # ,:relationship => params[:relationship],:is_keyholder => params[:key_holder][:is_keyholder])
          # end
          redirect_to :controller => 'call_list',:action => 'show',:id => params[:patient_id]
        else
          render :action => 'new_caregiver_profile',:user_id => current_user
          # raise "Invalid Profile"
        end
      else
        render :action => 'new_caregiver_profile',:user_id => current_user
        # raise "Invalid User"
      end
      # redirect_to :controller => 'call_list',:action => 'show',:id => params[:patient_id]

    # rescue Exception => e
    #   RAILS_DEFAULT_LOGGER.warn("ERROR signing up, #{e}")
    #   render :action => 'new_caregiver_profile'
    end
  end
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
      @senior = @user # User.find(params[:user_id]) # additional parameter passed for correct logic
      #    raise params.inspect
      begin
        User.transaction do
          user.update_attribute('email', params[:user][:email])
          if(!params[:roles_user_id].blank?)
            @roles_users_option = RolesUsersOption.find_by_roles_user_id(params[:roles_user_id])
            @roles_users_option.update_attributes!(params[:roles_users_option])
            @roles_users_option.relationship = params[:relationship]
            @roles_users_option.save!
          end

          if @profile.update_attributes!(params[:profile])
            if((current_user.is_super_admin? || current_user.is_admin_of_any?(user.group_memberships)) and user.is_halouser?)
              # https://redmine.corp.halomonitor.com/issues/3016
              # WARNING: DRYed code. needs more testing than just this ticket
              user.opt_out_call_center(!params[:opt_out_call_center].blank?) # check box is submitted only when selected
              #
              # CHANGED: old code
              # # group = Group.find_by_name('safety_care')
              # # if(params[:opt_out_call_center].blank?)
              # #   user.is_halouser_of group
              # # elsif(user.is_halouser_of? group)
              # #   role = Role.find(:first, :conditions => "name = 'halouser' AND authorizable_type = 'Group' AND authorizable_id = #{group.id}")
              # #   ru = RolesUser.find(:first, :conditions => "user_id = #{user.id} AND role_id = #{role.id}")
              # #   RolesUser.delete(ru)
              # # end
            end
          end
          # @alert_message = true
          # render :action => 'edit_caregiver_profile'
          redirect_to_message( 
            :message => ((current_user.is_super_admin? || current_user.is_admin_of_any?(user.group_memberships)) ? :profile_updated : :call_tech_support), 
            :back_url => url_for(:controller => "profiles", :action => "edit_caregiver_profile", :id => @profile.id, :user_id => user)
            )
          # redirect_to :controller => "alerts", :action => "alert"
        end
      rescue Exception => e
        render :action => 'edit_caregiver_profile'
      end
    else
      redirect_to :action => "edit_caregiver_profile", :id => current_user.profile.id, :user_id => current_user.id
    end
  end
  
  #  Wed Nov  3 04:07:13 IST 2010, ramonrails 
  #    FIXME: this should just be a simple REST form for profile update
  def change_password_init
    @user = User.find(params[:user_id])
    #render :partial => 'change_password_init'
  end
  
  def change_username
    #
    # Thu Sep 16 02:10:08 IST 2010 > https://redmine.corp.halomonitor.com/issues/3437
  	@user = User.find(params[:id]) # the selected user, not current_user
  	if request.post?
  		if @user.update_attributes(params[:user])
  			redirect_to :action => "edit_caregiver_profile", :id => current_user.profile.id, :user_id => current_user.id
  		else
  			render :action => 'change_username'
  		end
  	end
  end
  
  # Wed Nov  3 03:50:24 IST 2010, ramonrails
  # FIXME: this is a confused logic, actually here we have;
  #   params[:user][:id] == selected_user.id
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
      #  Wed Nov  3 04:40:07 IST 2010, ramonrails 
      #   FIXME: why are we validating here? this should be done in model
      [:password, :password_confirmation].each {|e| user.send("#{e}=", user_hash[e]) } # apply password
      #
      # save and collect errors for failures
      @message = user.errors.each_full(&:collect).join(', ') unless user.save
      #
      # old logic
      # if user_hash[:password] == user_hash[:password_confirmation]
      #   if user_hash[:password].length >= 4
      #     UtilityHelper.change_password_by_user_id(user.id, user_hash[:password])
      #   else
      #     @message = "Password must be at least 4 characters"
      #   end
      # else
      #   @message = "New Password must equal Confirm Password"
      # end
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