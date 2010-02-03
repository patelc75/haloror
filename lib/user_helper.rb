module UserHelper
  # 2010-02-01 accept default value for created_by_user
  #
  def populate_user(profile_hash,email,group,created_by_user = nil,opt_out_call_center = 0)
  	@user = User.new
  	@user.email = email #namdatory for all cases
  	User.transaction do
  		@user[:is_new_halouser] = true # skip validations except email
    	@user.created_by = (created_by_user || @user) # 2010-02-01 when not created by logged_in user, then it is direct_customer
    	if @user.save!
    	  unless profile_hash.blank? # TODO: handle better. 2010-02-01 profile not required for direct_online_customer
          @profile = Profile.new(profile_hash)
          @profile.user_id = @user.id
          if !@profile.save!
            raise "Invalid Profile"  
          end
        end
        @group = (group.is_a?(Group) ? group : Group.find_by_name(group)) # 2010-02-01 accept String or Group.instance
#          role = @user.has_role 'halouser'
        @user.is_halouser_of @group unless @group.blank? # 2010-02-01 !@group.nil? will have errors later
#          if opt_out_call_center.blank?
          @group = Group.find_by_name('safety_care') # TODO: 
          raise "safety_care group missing!" if @group.nil? 
          @user.is_halouser_of @group if !@group.nil?
#          end
      end
  	end
  end  
  
  def populate_subscriber(user,same_as_senior,add_caregiver,email,params_profile)
  	if same_as_senior == "1"  #subscriber same as senior
      @user = (user.is_a?(User) ? user : User.find_by_id(user)) # avoid searching again
    else
      if add_caregiver != "1"  #subscriber will also be a caregiver
        @user = User.populate_caregiver(email,user.to_i,nil,nil,params_profile) #sets up @user
  	  else  #subscriber will not be a caregiver
  	    @user = User.new
      	@user.email = email
      	@subscriber_profile = Profile.new(params_profile)
      	@subscriber_profile.save!
      	@user.profile = @subscriber_profile
	    	  
    	@user[:is_new_subscriber] = true
    	@user.save!
      end
    end
      @senior = User.find(user)
  	  role = @user.has_role 'subscriber', @senior
  	  @subscriber_user_id = @user.id
  end
end
