module UserHelper
  def populate_user(params,email,group,created_by_user,opt_out_call_center = 0)
  	@user = User.new
  	@user.email = email
  	User.transaction do
  		@user[:is_new_halouser] = true
    	@user.created_by = created_by_user
    	if @user.save!
          @profile = Profile.new(params)
          @profile.user_id = @user.id
          if !@profile.save!
            raise "Invalid Profile"  
          end
          @group = Group.find_by_name(group)
          @user.is_halouser_of @group if !@group.nil?
          if opt_out_call_center.blank?
            @group = Group.find_by_name('safety_care')
            raise "safety_care group missing!" if @group.nil? 
            @user.is_halouser_of @group if !@group.nil?
          end
        end
  	end
  end  
  
  def populate_subscriber(user,same_as_senior,add_caregiver,email,params_profile)
  	if same_as_senior == "1"  #subscriber same as senior
      @user = User.find_by_id(user)
    else
      if add_caregiver != "1"  #subscriber will also be a caregiver
        @user = User.populate_caregiver(email,user.to_i,nil,nil,params_profile) #sets up @user
  	  else  #subscriber will not be a caregiver
  	    @user = User.new
      	@user.email = email
      	@profile = Profile.new(params_profile)
      	@profile.save!
      	@user.profile = @profile
	    	  
    	@user[:is_new_subscriber] = true
    	@user.save!
      end
    end
      @senior = User.find(user)
  	  role = @user.has_role 'subscriber', @senior
  	  @subscriber_user_id = @user.id
  end
end
