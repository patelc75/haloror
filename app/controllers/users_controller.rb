class UsersController < ApplicationController  
  before_filter :authenticated?, :except => [:init_user, :update_user]

  def save_timezone
    user = User.find(current_user.id)
    user.profile.tz = tzinfo_from_timezone(TimeZone.new(params[:user][:timezone_name]))
    user.save
  end
  
  def tzinfo_from_timezone(timezone)
    TZInfo::Timezone.all.each do |tz|
      if tz.current_period.utc_offset.to_i == timezone.utc_offset.to_i
        return tz
      end
    end
    return nil   
  end
  
  def show
  	RAILS_DEFAULT_LOGGER.debug("****START show")
  	if params[:user_id]
  		@senior_user = User.find(params[:user_id])
  	end
	@user = User.new
    @profile = Profile.new
  render :action => 'credit_card_authorization'
  end
  
  def credit_card_authorization
  	RAILS_DEFAULT_LOGGER.debug("****START credit_card_authorization")
  	if params[:user_id]
  		@user = User.find(params[:user_id])
  	else
  		@user = User.new
  	end
    @profile = Profile.new
  end
  
  #handles 3 scanerios (1) new subscriber (1)subscriber same as senior (2)new subscriber also caregiver
  def create_subscriber
  	senior_user_id = params[:user_id]
  	@senior = User.find senior_user_id
  	if !request.post?  #clicking "skip" is a GET (vs a POST)
  	  #@user = User.find(params[:user_id])
  	else
  	  User.transaction do  	  
      	if params[:users][:same_as_senior] == "1"  #subscriber same as senior
      	  @user = User.find_by_id(params[:user_id])
      	  subscriber_user_id = senior_user_id
      	else
    	    if params[:users][:add_caregiver] != "1"  #subscriber will also be a caregiver
      	    @user = User.populate_caregiver(params[:email],params[:user_id].to_i,nil,nil,params[:profile]) #sets up @user
  	  	  else  #subscriber will not be a caregiver
  	  	    @user = User.new
      		  @user.email = params[:email]
      		  @profile = Profile.new(params[:profile])
      		  @profile.save!
      		  @user.profile = @profile
	    	  
    	  	  @user[:is_new_subscriber] = true
    	  	  @user.save!
    	    end
    		  subscriber_user_id = @user.id
        end
        #Credit Card auth needs to be in a transaction so subscriber/caregiver data can be rolled back
        Subscription.credit_card_validate(senior_user_id,subscriber_user_id,@user,params[:credit_card],flash)       		  
      end
  	  #this following does not need to be in the transaction because the lines above this do not need to be rolled back if the below lines fail
  	  halouser = User.find(params[:user_id].to_i)
  	  role = @user.has_role 'subscriber', halouser #@user set up in populate_caregiver when subscriber is also a caregiver
  	  UserMailer.deliver_subscriber_email(@user)
  	  UserMailer.deliver_signup_notification_halouser(@user,halouser)
    end

    rescue Exception => e
  	RAILS_DEFAULT_LOGGER.warn("ERROR in create_subscriber, #{e}")
  	RAILS_DEFAULT_LOGGER.debug(e.backtrace.join("\n"))
  	if request.post?
  		@senior_user = @senior
  	  render :action => 'credit_card_authorization'
    else
    	@senior = User.find(params[:id])
    end
  end

  def signup_info
  	
  	@user = User.find(params[:user_id])
  	
  	kit_serial_number = params[:kit][:serial_number]  
  	if (kit_serial_number == nil || kit_serial_number.size != 10 || kit_serial_number[0,2] != 'H4' ) 
  		msg = "Invalid serial number"	
  	else
  		msg = ""
  	end  
    kit_device = Device.find_by_serial_number(kit_serial_number)
    if kit_device
	  if kit_device.kits.first
	    kit = kit_device.kits.first
	    gw = kit.check_for_device_type('Gateway')
	    cs = kit.check_for_device_type('Chest Strap')
	    bc = kit.check_for_device_type('Belt Clip')
	    if gw == false
	      msg += "<br> Not found Gateway "
	    end
	
	    if cs == false && bc == false
	      msg += "<br> Not found Chest Strap or Belt Clip "
	    end
	  else
	    msg = "<br> Not found Kit Id"
	  end
    else
     @kit = KitSerialNumber.create(:serial_number => kit_serial_number,:user_id => @user.id)
     # msg = "<br> Not found Kit Number "
    end
    error_message = "Error(s):" + msg
    flash[:warning] = error_message
    if msg != ""
      redirect_to "/users/create_subscriber/#{@user.id}"
    else
      if !@kit
        params[:gateway_serial_number] = gw.serial_number
        params[:strap_serial_number] = cs.serial_number if cs != false
        params[:strap_serial_number] = bc.serial_number if bc != false
        map_serial_numbers
      end
      UserMailer.deliver_kit_serial_number_register(@user, kit_serial_number, current_user)
      @subscription = Subscription.find_by_subscriber_user_id(params[:user_id])
    end

  end
  
  def receipt
  	@subscription = Subscription.find_by_subscriber_user_id(1)
  	@user = User.find(params[:id])
  end
  
  def edit_serial_number
  	@user = User.find(params[:id])
    @gateway = Device.new
    @strap = Device.new	
  end
  
  def map_serial_numbers
  	  	@user = User.find(params[:user_id])
  	gateway_serial_number = params[:gateway_serial_number]
    
    unless gateway_serial_number
      gateway_serial_number = params[:gateway][:serial_number]      
    end
    #check if gateway exists
    if !gateway_serial_number.blank?
      if gateway_serial_number.size == 7
        gateway_serial_number = gateway_serial_number[0,2] + "000" + gateway_serial_number[2, 5] 
      end

      @gateway = Device.find_by_serial_number(gateway_serial_number)
      unless @gateway
      	params[:gateway][:serial_number] = gateway_serial_number
        @gateway = @user.devices.build(params[:gateway])
      end
      begin
        @gateway.set_gateway_type
        @gateway.save!
      rescue Exception => e
        flash[:warning] = "#{e}"
        throw e
      end
    else
      msg = "Gateway Serial Number cannot be blank."
      flash[:warning] = msg
      throw msg
    end
    
    strap_serial_number = params[:strap_serial_number]
    unless strap_serial_number #two diff param locations because they're used on different forms
      strap_serial_number = params[:strap][:serial_number]
    end
    if !strap_serial_number.blank?
      if strap_serial_number.size == 7  #in case there's a short serial number
        strap_serial_number = strap_serial_number[0,2] + "000" + strap_serial_number[2, 5] 
      end
      @strap = Device.find_by_serial_number(strap_serial_number)
      if @strap && !@strap.users.blank? && !@strap.users.include?(@user)
        flash[:warning] = "Chest Strap with Serial Number #{strap_serial_number} is already assigned to a user."
        @remove_link = true
        throw Exception.new
      end
      unless @strap
      	params[:strap][:serial_number] = strap_serial_number
        @strap = @user.devices.build(params[:strap]) 
      end
      begin
        @strap.set_chest_strap_type
        @strap.save!
      rescue Exception => e
        flash[:warning] = "#{e}"
        throw e
      end
    else
      msg = "Chest Strap/Belt Clip Serial Number cannot be blank."
      flash[:warning] = msg
      throw msg
    end
  end
  
  def create_serial_number
  	
	map_serial_numbers
    redirect_to :controller => 'profiles',:action => 'edit_caregiver_profile',:id => @user.profile.id,:user_id => @user.id

    #redirect_to "/profiles/edit_caregiver_profile/#{@user.profile.id}/?user_id=#{@user.id]}"
    rescue Exception => e
    RAILS_DEFAULT_LOGGER.warn("ERROR registering devices, #{e}")
  	render :action => 'edit_serial_number'
  end
  
  def new
  	RAILS_DEFAULT_LOGGER.debug("****START new")

    @user = User.new
    @profile = Profile.new
    @groups = []
    if current_user.is_super_admin?
      @groups = Group.find(:all)
    else
      gs = current_user.group_memberships
      gs.each do |g|
        @groups << g if(current_user.is_sales_of?(g) || current_user.is_admin_of?(g))
      end
	end
  end

  def create  	
    @user = User.new(params[:user])
    @user.email = params[:email]
    @group = params[:group]
    @profile = Profile.new(params[:profile])
    if !@group.blank? && @group != 'Choose a Group'
      User.transaction do
        @user[:is_new_halouser] = true
        @user.created_by = current_user.id
        if @user.save!
          @profile.user_id = @user.id
          if !@profile.save!
            raise "Invalid Profile"  
          end
          group = Group.find_by_name(@group)
          @user.is_halouser_of group if !group.nil?
          if(params[:opt_out_call_center].blank?)
            group = Group.find_by_name('safety_care')
            raise "safety_care group missing!" if group.nil? 
            @user.is_halouser_of group if !group.nil?
          end
          
          redirect_to :controller => 'users', :action => 'credit_card_authorization',:user_id => @user.id
        else
          raise "Invalid User"
        end
      end
    else 
      flash[:warning] = "Group is Required"
      redirect_to :controller => 'users', :action => 'new'
    end
    
    rescue Exception => e
      RAILS_DEFAULT_LOGGER.warn("ERROR signing up, #{e}")
       @groups = []
        gs = current_user.group_memberships
        gs.each do |g|
          @groups << g if(current_user.is_sales_of?(g) || current_user.is_admin_of?(g) || current_user.is_super_admin?)
        end
      render :action => 'new'
  end
  def validation
  	@user = User.new
  	@user.email = "test@test.com"
  	if @user.email.valid?
  		render :text => 'valid'
  	else
  		render :text => @user.errors.size
  	end
  end
  def user_intake_form
    if request.post?
    	@user = User.new
    	@user.email = params[:user_email]
    	User.transaction do
    		@user[:is_new_halouser] = true
            @user.created_by = current_user.id
            if @user.save!
            	debugger
            	@profile = Profile.new(params[:user])
            	@profile.user_id = @user.id
            	@profile.save!
                group = Group.find_by_name('halouser')
                @user.is_halouser_of group if !group.nil?
            end
            
            @subscription = Subscription.new
	        @subscription[:senior_user_id] = @user.id
            if params[:same_as_user] and params[:same_as_user] == 'on'
            	debugger
              halouser = User.find(@user.id)
              @subscription[:subscriber_user_id] = @user.id
              @subscription[:bill_to_first_name] = halouser.profile.first_name
		      @subscription[:bill_to_last_name] = halouser.profile.last_name
		      @subscription[:bill_amount] = halouser.group_recurring_charge
		      
              @subscription.save!
  	          role = @user.has_role 'subscriber', halouser
  	          UserMailer.deliver_subscriber_email(@user)
  	          UserMailer.deliver_signup_notification_halouser(@user,halouser)
  	        else
  	        	@subscriber = User.new
  	        	@subscriber.email = params[:subscriber_email]
  	        	@subscriber[:is_new_subscriber] = true
  	        	
  	        	if @subscriber.save!
  	        		@subscriber_profile = Profile.new(params[:subscriber])
  	        		#@subscriber_profile.last_name = 'test'
  	        		@subscriber_profile.user_id = @subscriber.id
  	        		@subscriber_profile.save
  	        		subscriber = User.find(@subscriber.id)
  	        		@subscription[:bill_to_first_name] = subscriber.profile.first_name
		      		@subscription[:bill_to_last_name] = subscriber.profile.last_name
  	        		@subscription[:bill_amount] = subscriber.group_recurring_charge
  	        		@subscription[:subscriber_user_id] = @subscriber.id
  	        		@subscription.save!
  	        		role = @subscriber.has_role 'subscriber', @user
  	                UserMailer.deliver_subscriber_email(@subscriber)
  	                UserMailer.deliver_signup_notification_halouser(@subscriber,@user)
  	        	end
            end
unless params[:no_caregiver_1]
@car1 = User.populate_caregiver(params[:caregiver1_email],@user.id,nil,nil,params[:caregiver1]) 
@roles_users_option_car1 = RolesUsersOption.find_by_roles_user_id(@user.roles_user_by_caregiver(@car1).id)
@roles_users_option_car1.is_keyholder = params[:car1_roles_users_option][:is_keyholder] = '1'? true:false
@roles_users_option_car1.phone_active = params[:car1_roles_users_option][:phone_active] == 'on'? true:false
@roles_users_option_car1.email_active = params[:car1_roles_users_option][:email_active] == 'on'? true:false
@roles_users_option_car1.text_active = params[:car1_roles_users_option][:text_active] == 'on'? true:false
@roles_users_option_car1.save
end
unless params[:no_caregiver_2]
@car2 = User.populate_caregiver(params[:caregiver2_email],@user.id,nil,nil,params[:caregiver2])
@roles_users_option_car2 = RolesUsersOption.find_by_roles_user_id(@user.roles_user_by_caregiver(@car2).id)
@roles_users_option_car2.is_keyholder = params[:car2_roles_users_option][:is_keyholder] = '1'? true:false
@roles_users_option_car2.phone_active = params[:car2_roles_users_option][:phone_active] == 'on'? true:false
@roles_users_option_car2.email_active = params[:car2_roles_users_option][:email_active] == 'on'? true:false
@roles_users_option_car2.text_active = params[:car2_roles_users_option][:text_active] == 'on'? true:false
@roles_users_option_car2.save
end
unless params[:no_caregiver_3]
@car3 = User.populate_caregiver(params[:caregiver3_email],@user.id,nil,nil,params[:caregiver3]) 
@roles_users_option_car3 = RolesUsersOption.find_by_roles_user_id(@user.roles_user_by_caregiver(@car3).id)
@roles_users_option_car3.is_keyholder = params[:car3_roles_users_option][:is_keyholder] = '1'? true:false
@roles_users_option_car3.phone_active = params[:car3_roles_users_option][:phone_active] == 'on'? true:false
@roles_users_option_car3.email_active = params[:car3_roles_users_option][:email_active] == 'on'? true:false
@roles_users_option_car3.text_active = params[:car3_roles_users_option][:text_active] == 'on'? true:false
@roles_users_option_car3.save
end
    	end
    	redirect_to :action => 'user_intake_form'
	end
  	
  end
  
  def signup_details
  	@user = User.find params[:id]
  	@alert_types = []
  	AlertType.find(:all).each do |type|    
      @alert_types << type        
    end
  end
  
  def add_device_to_user
    if valid_serial_number(params[:serial_number])
    	register_user_with_serial_num(User.find(params[:user_id]),params[:serial_number].strip)
    else
    	flash[:notice] = "Not Valid Serial Number, Serial number must be exactly 10 digits."
    end
    	redirect_to :controller => 'reporting', :action => 'users'
  end
  
  def valid_serial_number(serial_number)
  	if serial_number.length != 10
  		return false	
  	else
  		return true
  	end
  end
  
  def activate
    user = User.find_by_activation_code(params[:activation_code])
    if !user.activated?
      user.activate
      #flash[:notice] = "Signup complete!"
    end
    #redirect_back_or_default('/')
  end
  
  def init_user
    @user = User.find_by_activation_code(params[:activation_code])
    if @user
      if !@user.login.nil? and !@user.crypted_password.nil?
    	@user.activation_code = nil
    	@user.activated_at = Time.now.utc
    	@user.save
    	if params[:senior]
    	  senior = User.find params[:senior]
    	  role_user = senior.roles_user_by_caregiver(@user)
    	  RolesUsersOption.update(role_user.roles_users_option.id, {:active => 1,:position => User.get_max_caregiver_position(senior)})
  	    end
        redirect_to('/login')
      else
        session[:senior] = params[:senior]	
      end
    end
  end
  
  def update_user
   @user = User.find_by_activation_code(params[:user][:activation_code])
   
    user_hash = params[:user]
    if user_hash[:password] == user_hash[:password_confirmation]
      if user_hash[:password].length >= 4
        @user.password = user_hash[:password]
        @user.password_confirmation = user_hash[:password_confirmation]
        @user.login = user_hash[:login]
        @user.save!
        self.current_user = @user
        if logged_in? && !current_user.activated?
          current_user.activate
        end
        current_user.set_active()
        if current_user.is_caregiver?
          	if session[:senior]
        		redirect_to :controller => 'call_list', :action => 'show', :id => session[:senior]
        	else
          		redirect_to :controller => 'call_list', :action => 'show', :recently_activated => 'true'
      		end
        else
          redirect_to '/'
        end
      else
        flash[:warning] = "Password must be at least 4 characters"
        render :action => 'init_user'
      end
    else
        flash[:warning]= "New Password must equal Confirm Password"
        render :action => 'init_user'
    end
    
  rescue
    render :action => 'init_user'    
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
    @senior = User.find(params[:user_id].to_i)    
    
    @removed_caregivers = []
    @senior.caregivers.each do |caregiver|
      if caregiver
        roles_user = @senior.roles_user_by_caregiver(caregiver)
        #caregiver.roles_users.each do |roles_user|
          if roles_user.roles_users_option and roles_user.roles_users_option[:removed]
            @removed_caregivers << caregiver
          end
        #end 
      end
    end
    
    @max_position = User.get_max_caregiver_position(@senior)
    
    @password = random_password
    
    @user = User.new 
    @profile = Profile.new  
    render :layout => false
  end
  
  def existing_info
    @user_info = User.find(params[:id])
    @user_cell_info = @user_info.profile.cell_phone
    @user_home_info = @user_info.profile.home_phone
    @user_carrier_id = @user_info.profile.carrier_id
    type = 'caregiver'
    if !params[:operator].blank?
      type = 'operator'
    end
    missing_what = nil

    if ("text" == params[:what])
      if (@user_cell_info == nil || @user_carrier_id == nil ||@user_cell_info == "" || @user_carrier_id == "" )
        missing_what = "The #{type} must include both a Cell Phone and Cell Carrier Provider. Would you like to enter both now?" 
      end
    end


    if ("phone" == params[:what])
     if ((@user_cell_info == "" or @user_cell_info == nil) and (@user_home_info == nil or @user_home_info == "" ))
         missing_what = "This #{type} must have either a Cell Phone or a Home Phone? Would you like enter one or both now?"
       end
    end
  render :partial => 'call_list/extra_info_lightbox', :locals => {:id => params[:id], :user_id => params[:user_id], :missing => missing_what} 
    
  end

  def refresh
    @user = User.find(params[:user_id])
    refresh_caregivers(@user)
  end
=begin  
  def populate_caregiver(email,patient_id=nil, position = nil,login = nil,profile_hash = nil)
  	existing_user = User.find_by_email(email)
  	if !login.nil? and login != ""
  	  @user = User.find_by_login(login)
  	elsif !existing_user.nil? 
  	  @user = existing_user
	  else
  	  @user = User.new
  	  @user.email = email
  	end
  	
  	if !@user.email.blank?
		  @user.is_new_caregiver = true
  		@user[:is_caregiver] =  true
  		@user.save!

  		if @user.profile.nil?
  		  if profile_hash.nil?
  		    profile = Profile.new(:user_id => @user.id)
  		  else
  		  	profile = Profile.new(profile_hash)
  		  end
  		  profile[:is_new_caregiver] = true
  		  profile.save!
  		  @user.profile = profile
  		end
  		
  		patient = User.find(patient_id)

  		if position.nil?
  		  position = User.get_max_caregiver_position(patient)
  		end
  		
  		role = @user.has_role 'caregiver', patient #if 'caregiver' role already exists, it will return nil
  		caregiver = @user
  		@roles_user = patient.roles_user_by_caregiver(caregiver)

  		update_from_position(position, @roles_user.role_id, caregiver.id)

  		#enable_by_default(@roles_user)      
  		#redirect_to 	"/profiles/edit_caregiver_profile/#{profile.id}/?user_id=#{params[:user_id]}&roles_user_id=#{@roles_user.id}"
  
  		#if role.nil? then the roles_user does not exist already
  		RolesUsersOption.create(:roles_user_id => @roles_user.id, :position => position, :active => 0) if !role.nil?
  
  		if existing_user.nil?
    		UserMailer.deliver_caregiver_email(caregiver, patient)
  		end
    end
  end
=end  
  def create_caregiver
    User.transaction do  	  
	    User.populate_caregiver(params[:user][:email],params[:user_id].to_i,params[:position],params[:user][:login])
    end
      
    render :partial => 'caregiver_email'
=begin
  rescue Exception => e
    RAILS_DEFAULT_LOGGER.warn "#{e}"
    # check if email exists
    if existing_user = User.find_by_email(params[:user][:email])
      @existing_id = existing_user[:id]
      @add_existing = true
    end
   
  # old code without if else
   #render :partial => 'caregiver_form'
  
   #new code with if else and created a new partial existing_caregiver_form and removed <% if @add_existing %> function in  caregiver_form   
    @max_position = User.get_max_caregiver_position(@user)
     if (@add_existing == true )
         render :partial => 'existing_caregiver_form'
         else
         render :partial => 'caregiver_form'
    end
=end
  end  
  
  def destroy_operator
    RolesUsersOption.update(params[:id], {:removed => 1, :position => 0})
    @operators = User.operators
    number_ext
    render :layout =>false, :partial => 'call_center/operators'
  end
  
  def destroy_caregiver
    option = RolesUsersOption.find(params[:id])
    
    #get all roles_users_options above the position you want to delete at
    options = RolesUsersOption.find(:all, :conditions => "position > #{option.position} and roles_users.role_id = #{option.roles_user.role_id}", :include => :roles_user )
    
    options.each do |opt|
      opt.position-=1
      opt.save
    end
    RolesUsersOption.update(params[:id], {:removed => 1, :position => 0})
    render :layout =>false
  end
  
  def restore_caregiver_role
    user = User.find(params[:user_id])
    
    opt = RolesUsersOption.find(params[:id])
    opt.removed = false
    opt.position = User.get_max_caregiver_position(user)
    opt.save
    
    refresh_caregivers(user)
  end
  
  def add_existing
    @patient = User.find(params[:user_id])
    params[:patient_id] = params[:user_id]
    @caregiver = User.find(params[:id])
    
    role = @caregiver.has_role 'caregiver', @patient
    @roles_user = @patient.roles_user_by_caregiver(@caregiver)
    
    unless opt = RolesUsersOption.find(:first, :conditions => "roles_user_id = #{@roles_user.id}")
      opt = RolesUsersOption.create(:roles_user_id => @roles_user.id)
    end
    
    opt.active = true
    opt.position = User.get_max_caregiver_position(@patient)
    #opt.position = 1
    opt.removed = false
    opt.save
    
    refresh_caregivers(@patient)
  end
=begin  
  def update_from_position(position, roles_user_id, user_id)
    caregivers = RolesUsersOption.find(:all, :conditions => "position >= #{position} and roles_user_id = #{roles_user_id}")
    
    caregivers.each do |caregiver|
      caregiver.position+=1
      caregiver.save
    end
  end
=end  
  def random_password
    Digest::SHA1.hexdigest("--#{Time.now.to_s}--")[0,6]
  end
    
  def register_user_with_serial_num(user, serial_number)
    unless device = Device.find_by_serial_number(serial_number)
      device = Device.new
      device.serial_number = serial_number
      # if(device.serial_number[0].chr == 'H' and device.serial_number[1].chr == '1')
      #         device.set_chest_strap_type
      #       elsif(device.serial_number[0].chr == 'H' and device.serial_number[1].chr == '2')
      #         device.set_gateway_type
      #       end
      device.save!
    end

    if device.device_type.blank?
      if(device.serial_number[0].chr == 'H' and device.serial_number[1].chr == '1')
        device.set_chest_strap_type
      elsif(device.serial_number[0].chr == 'H' and device.serial_number[1].chr == '2')
        device.set_gateway_type
      end   
    end
    device.users << user
    device.save!
  end
    

=begin  
  def enable_by_default(roles_user)
  	
  	  ALERTS_ENABLED_BY_DEFAULT.each do |type|
  	    alert_type = AlertType.find_by_alert_type(type)
      
        alert_opt = AlertOption.new
        alert_opt.roles_user_id = roles_user.id
        alert_opt.alert_type_id = alert_type.id
        alert_opt.phone_active = true
        alert_opt.email_active = true
        alert_opt.text_active = true
        alert_opt.save
  	  end
  end
=end  
end
