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
  
  def setup_subscriber(params_hash)
    if params_hash["senior_object"].nil? 
      raise "senior_object is needed so we know who the subscriber is a subscriber for"
    elsif params_hash["same_as_senior"] == true and params_hash["add_as_caregiver"] == true
      raise "senior cannot be caregiver of themselves"
    end
    
    if params_hash["same_as_senior"] == true
      subscriber = params_hash["senior_object"]
    elsif params_hash["add_as_caregiver"] == true
      subscriber = User.populate_caregiver(params_hash["email"],params_hash["senior_object"].id, nil, nil,params_hash["profile_hash"])
    elsif !params_hash["email"].nil? or !params_hash["profile_hash"].nil?
      subscriber = User.new
      subscriber.email = params_hash["subscriber_email"] if !params_hash["subscriber_email"].nil?
      subscriber_profile = Profile.new(params_hash["profile_hash"])
    	subscriber_profile.save!
    	subscriber_profile.profile = subscriber_profile
    	subscriber[:is_new_subscriber] = true
    	subscriber.save!
    end
    
    role = subscriber.has_role 'subscriber', params_hash["senior_object"]
  end
  
  def self.setup_subscriber_test()
    profile_hash = {"work_phone"=>"", "city"=>"Brooklyn", "carrier_id"=>"", "zipcode"=>"", "cell_phone"=>"", "home_phone"=>"", "time_zone"=>"Central Time (US & Canada)", "first_name"=>"af", "address"=>"1212 W. Grand Ave", "last_name"=>"ads", "state"=>"ny"}
    senior = User.first
    
    subscriber_hash = { "email" => "halo_subscriber@chirag.name", "profile_hash" => profile_hash , "senior_object" => senior }
    subscriber_hash = { "email" => "halo_subscriber@chirag.name", "profile_hash" => profile_hash , "senior_object" => senior, "add_as_caregiver" => true }
    subscriber_hash = { "senior_object" => senior }
    
    setup_subscriber(subscriber_hash)
  end
end
