module UserHelper
  # 2010-02-01 accept default value for created_by_user
  #
  def populate_user(profile_hash, email, group, created_by_user = nil, opt_out_call_center = 0)
  	@user = User.new
  	@user.email = email #namdatory for all cases
  	User.transaction do
  		@user[:is_new_halouser] = true # skip validations except email
    	@user.created_by = (created_by_user || @user) # 2010-02-01 when not created by logged_in user, then it is direct_customer
    	if @user.save!
    	  unless profile_hash.blank? # FIXME: handle better. 2010-02-01 profile not required for direct_online_customer
          @profile = Profile.new(profile_hash)
          @profile.user_id = @user.id
          #
          # we need to reload @user object because the @profile was created later
          ((@user = @profile.user) if @profile.save!) unless !@profile.valid? # do not throw code to browser here. ! will force validation
        end
        
        # FIXME: avoid instance variable. It is over-written here anyways
        @group = (group.is_a?(Group) ? group : Group.find_by_name(group)) # 2010-02-01 accept String or Group.instance
        # role = @user.has_role 'halouser'
        @user.is_halouser_of @group unless @group.blank? # 2010-02-01 !@group.nil? will have errors later
        # if opt_out_call_center.blank?
        @group = Group.find_or_create_by_name('safety_care') #FIXME: just create if it does not exist
        # raise "safety_care group missing!" if @group.nil? 
        @user.is_halouser_of @group if !@group.nil?
        # end
      end
  	end
  end  
  
  #user = senior user object or senior user id
  #email = subscriber email
  #params_profile = subscriber profile
  def populate_subscriber(user,same_as_senior,add_caregiver,email,params_profile)#,roles_users_hash = {})
  	if same_as_senior == "1"  #subscriber same as senior
      @user = (user.is_a?(User) ? user : User.find_by_id(user)) # avoid searching again
    else
      if add_caregiver != "1"  #subscriber will also be a caregiver
        @user = User.populate_caregiver(email,user.to_i,nil,nil,params_profile)#,roles_users_hash) #sets up @user
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
  
  # TODO: This should ideally be done using 'Subscriber < User' model
  #   subscriber.build(params[:subscriber]) is the ideal call in user_intake model
  #   subscriber belongs_to user_intake
  #
  def setup_subscriber(params_hash)
    subscriber = subscriber_profile = nil # Something to begin with. We have to return some value.
    
    unless params_hash.blank?
      if params_hash["senior_object"].nil? 
        raise "senior_object is needed so we know who the subscriber is a subscriber for"
        
      elsif params_hash["same_as_senior"] == true and params_hash["add_as_caregiver"] == true
        raise "senior cannot be caregiver of themselves"
      end

      if params_hash["same_as_senior"]
        subscriber = params_hash["senior_object"]
        subscriber_profile = subscriber.profile unless subscriber.blank?
        
      elsif params_hash["add_as_caregiver"] == true
        subscriber = User.populate_caregiver(params_hash["email"],params_hash["senior_object"].id, nil, nil,params_hash["profile_hash"])
        subscriber_profile = subscriber.profile unless subscriber.blank?

      # FIXME: Incorrect condition here. where is params_hash["email"] used?
      elsif !(params_hash["email"].blank? || params_hash["profile_hash"].blank?)
        subscriber = User.new
        subscriber.email = params_hash["email"] unless params_hash["email"].blank?
        subscriber_profile = Profile.new(params_hash["profile_hash"])
        #
        # FIXME: profile should be saved "after" User? It has reference to user.id
        if subscriber_profile.valid? # check before saving. avoid tech crash on browser
        	if subscriber_profile.save!
          	subscriber.profile = subscriber_profile
          	subscriber[:is_new_subscriber] = true
          	subscriber.save! rescue nil # tech stuff is not for browser
        	end
        end
      end

      subscriber.has_role 'subscriber', params_hash["senior_object"] unless subscriber.blank?
    end
    #
    # CHANGED: this method should return some value unless we use instance variables
    # returns: subscriber, subscriber_profile, success (boolean)
    return subscriber, subscriber_profile, \
      ( !subscriber.blank? && !subscriber_profile.blank? && \
        subscriber.is_a?(ActiveRecord::Base) && subscriber_profile.is_a?(ActiveRecord::Base) && \
        subscriber.errors.count.zero? && subscriber_profile.errors.count.zero?
      )
  end
  
  def self.setup_subscriber_test
    profile_hash = {"work_phone"=>"", "city"=>"Brooklyn", "carrier_id"=>"", "zipcode"=>"", "cell_phone"=>"", "home_phone"=>"", "time_zone"=>"Central Time (US & Canada)", "first_name"=>"af", "address"=>"1212 W. Grand Ave", "last_name"=>"ads", "state"=>"ny"}
    senior = User.first
    
    subscriber_hash = { "email" => "halo_subscriber@chirag.name", "profile_hash" => profile_hash , "senior_object" => senior }
    subscriber_hash = { "email" => "halo_subscriber@chirag.name", "profile_hash" => profile_hash , "senior_object" => senior, "add_as_caregiver" => true }
    subscriber_hash = { "senior_object" => senior }
    
    setup_subscriber(subscriber_hash)
  end

  # find a user record by login or full name in profile.
  # full name will be split and [0], [-1] values used to search first and last names
  #
  def find_profile_user(full_name)
    name = split_phrase(full_name)
    profile = Profile.find_by_first_name_and_last_name(name.first, name.last)
    user = profile.user unless profile.blank?
    user
  end
  
  # these variables are used when adding a "new caregiver"
  def load_values_to_allow_new_caregiver(user_id)
    @senior = User.find(user_id.to_i)
    @removed_caregivers = []
    @senior.caregivers.each do |caregiver|
      roles_user = @senior.roles_user_by_caregiver(caregiver)
      @removed_caregivers << caregiver \
        if roles_user.roles_users_option && roles_user.roles_users_option[:removed]
    end unless @senior.blank?
    @max_position = User.get_max_caregiver_position(@senior)
    @password = random_password
    @user = User.new 
    @profile = Profile.new
  end
end
