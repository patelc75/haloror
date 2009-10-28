require "ArbApiLib"

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
  
  def create_subscriber
  	
  	RAILS_DEFAULT_LOGGER.debug("****START create_subscriber")
  	
	senior_user_id = params[:user_id]
	if !request.post?  # when click on the skip this page
	  @user = User.find(params[:user_id])
	  session[:new_user] = nil
	else
  	  if params[:users][:same_as_senior] == "1"
  	    @user = User.find_by_id(params[:user_id])
  		subscriber_user_id = senior_user_id
		RAILS_DEFAULT_LOGGER.debug("**same as senior == 1 ; subscriber_user_id = #{@senior_user_id}")
		bill_to_fn = @user.profile.first_name
		bill_to_ln = @user.profile.last_name
		credit_card_validate(senior_user_id,subscriber_user_id,@user)
  	  else
  	    User.transaction do
  		  if params[:users][:add_caregiver] != "1"
    	    populate_caregiver(params[:email],params[:users],params[:user_id].to_i)
	  	  else
	  	    @user = User.new
  			@user.email = params[:email]
  			@profile = Profile.new(params[:profile])
	  		@user[:is_new_user] = true
	  		if @user.save!
	    	  @profile.user_id = @user.id
	    	end
	    	@profile.save!
  	      end
  			subscriber_user_id = @user.id
  			credit_card_validate(senior_user_id,subscriber_user_id,@user)
  		end
	
	  end
	  @senior = User.find(senior_user_id)
	  patient = User.find(params[:user_id].to_i)
	  role = @user.has_role 'subscriber', patient
  
	  	# End authorize.net create subscription code 	
  	end

    rescue Exception => e
	  RAILS_DEFAULT_LOGGER.warn("ERROR in create_subscriber, #{e}")
	  RAILS_DEFAULT_LOGGER.debug(e.backtrace.join("\n"))
	  if request.post?
	    render :action => 'credit_card_authorization'
  	  else
  		@user = User.find(params[:id])
  	  end
  end
  
  def signup_info
  	
  	@user = User.find(params[:user_id])
  	
  	kit_serial_number = params[:kit][:serial_number] 
    @kit = KitSerialNumber.create(:serial_number => kit_serial_number,:user_id => @user.id)
    UserMailer.deliver_kit_serial_number_register(@user,@kit)
    @subscription = Subscription.find_by_subscriber_user_id(params[:user_id])
    
=begin  	
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
    unless strap_serial_number
      strap_serial_number = params[:strap][:serial_number]
    end
    if !strap_serial_number.blank?
      if strap_serial_number.size == 7
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
      msg = "Chest Strap Serial Number cannot be blank."
      flash[:warning] = msg
      throw msg
    end
=end
 # 	rescue Exception => e
 #   RAILS_DEFAULT_LOGGER.warn("ERROR registering devices, #{e}")
 # 	render :action => 'create_subscriber'
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
  
  def create_serial_number
  	
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
      msg = "Chest Strap Serial Number cannot be blank."
      flash[:warning] = msg
      throw msg
    end
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
    gs = current_user.group_memberships
    gs.each do |g|
      @groups << g if(current_user.is_sales_of?(g) || current_user.is_admin_of?(g) || current_user.is_super_admin?)
    end
  end

  def create
  	
  	  RAILS_DEFAULT_LOGGER.debug("****START create")

   
      @user = User.new(params[:user])
      @user.email = params[:email]
      @group = params[:group]
      @profile = Profile.new(params[:profile])
    if !@group.blank? && @group != 'Choose a Group'
  
      User.transaction do
          @user[:is_new_user] = true
          if @user.save
            # create profile
            @profile.user_id = @user.id
            if @profile.save
          
            else
              raise "Invalid Profile"  
            end
            # create halouser role
            @user.is_halouser_of Group.find_by_name(@group)
            if(current_user.is_super_admin? || current_user.is_admin_of_any?(@user.group_memberships))
              if(params[:opt_out_call_center].blank?)
                @user.is_halouser_of Group.find_by_name('SafetyCare')
              end
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
    session[:senior] = params[:senior]
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
          redirect_to :controller => 'call_list', :action => 'show', :recently_activated => 'true'
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
    senior = User.find(params[:user_id].to_i)    
    
    @removed_caregivers = []
    senior.caregivers.each do |caregiver|
      if caregiver
        roles_user = senior.roles_user_by_caregiver(caregiver)
        #caregiver.roles_users.each do |roles_user|
          if roles_user.roles_users_option and roles_user.roles_users_option[:removed]
            @removed_caregivers << caregiver
          end
        #end 
      end
    end
    
    @max_position = get_max_caregiver_position(current_user)
    
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
  
  def populate_caregiver(email,user = nil, patient=nil, position = nil,login = nil)
  	existing_user = User.find_by_email(email)
  	if !login.nil?
  		@user = User.find_by_login(login)
  	elsif !existing_user.nil? 
  	  @user = existing_user
	  else
  		@user = User.new
  		@user.email = email
  	end
  	if !@user.email.blank?
    	User.transaction do
  			
  			@user.is_new_caregiver = true
    		@user[:is_caregiver] =  true
    		@user.save!
    		if position == nil
    			position = get_max_caregiver_position(@user)
    		end
    		@user.profile.nil? ? profile = Profile.new(:user_id => @user.id) : profile = @user.profile
    		profile[:is_new_caregiver] = true
    		profile.save!
    
      		#patient = User.find(params[:user_id].to_i)
      		patient = User.find(patient)
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
    
  end
  
  def create_caregiver    
    
      populate_caregiver(params[:user][:email],params[:user],params[:user_id].to_i,params[:position],params[:user][:login])
      
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
    @max_position = get_max_caregiver_position(@user)
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
    opt.position = get_max_caregiver_position(user)
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
    opt.position = get_max_caregiver_position(@patient)
    #opt.position = 1
    opt.removed = false
    opt.save
    
    refresh_caregivers(@patient)
  end
  
  def get_max_caregiver_position(user)
    #get_caregivers(user)
    #@caregivers.size + 1  #the old method would not work if a position num was skipped
    max_position = 1
    user.caregivers.each do |caregiver|
      roles_user = user.roles_user_by_caregiver(caregiver)
      if opts = roles_user.roles_users_option
        if opts.position >= max_position
          max_position = opts.position + 1
        end
      end
    end
    return max_position    
  end
  
  def update_from_position(position, roles_user_id, user_id)
    caregivers = RolesUsersOption.find(:all, :conditions => "position >= #{position} and roles_user_id = #{roles_user_id}")
    
    caregivers.each do |caregiver|
      caregiver.position+=1
      caregiver.save
    end
  end
  
  def random_password
    Digest::SHA1.hexdigest("--#{Time.now.to_s}--")[0,6]
  end
  
  private
#  def get_device_type(device)
#    if(device.serial_number == nil)
#      device_type = "Invalid serial num"
#    elsif(device.serial_number.length != 10)
#      device_type = "Invalid serial num"
#    elsif(device.serial_number[0].chr == 'H' and device.serial_number[1].chr == '1')
#      device_type = "Halo Chest Strap"
#    elsif(device.serial_number[0].chr == 'H' and device.serial_number[1].chr == '2')
#      device_type = "Halo Gateway"
#    else
#      device_type = "Unknown Device"
#    end
#    
#    device_type
#  end
  
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
  
  private
  
  def credit_card_validate(senior_user_id,subscriber_user_id,user)
  		bill_to_fn = user.profile.first_name
		bill_to_ln = user.profile.last_name
  	  	
		
  		#@gateway = Device.new
  		#@strap = Device.new    

    	# Start authorize.net create subscription code
  		auth = MerchantAuthenticationType.new(AUTH_NET_LOGIN, AUTH_NET_TXN_KEY)
  		# subscription name - use subscriber user id
		subname = "sen_uid-#{senior_user_id}-sub_uid-#{subscriber_user_id}"

		RAILS_DEFAULT_LOGGER.info("Attempting to create Authorize.Net subscription.  Subscription name = #{subname}")
		RAILS_DEFAULT_LOGGER.debug("Authorize.Net AUTH_NET_LOGIN= #{AUTH_NET_LOGIN}, AUTH_NET_TXN_KEY= #{AUTH_NET_TXN_KEY}")

	  	# 1 month interval
		interval = IntervalType.new(AUTH_NET_SUBSCRIPTION_INTERVAL, AUTH_NET_SUBSCRIPTION_INTERVAL_UNITS)

		sub_start_date = Time.now
		schedule = PaymentScheduleType.new(interval, sub_start_date.strftime("%Y-%m-%d"), AUTH_NET_SUBSCRIPTION_TOTAL_OCCURANCES, 0)
	
		RAILS_DEFAULT_LOGGER.info("Authorize.Net Subscription startdate = #{sub_start_date.strftime("%Y-%m-%d")} num_occurances = #{AUTH_NET_SUBSCRIPTION_TOTAL_OCCURANCES} interval = #{AUTH_NET_SUBSCRIPTION_INTERVAL} interval_units = #{AUTH_NET_SUBSCRIPTION_INTERVAL_UNITS}")
	
		cc_exp = "#{params[:credit_card][:"expiration_time(1i)"]}-#{params[:credit_card][:"expiration_time(2i)"]}"

		cinfo = CreditCardType.new(params[:credit_card][:number], cc_exp)
		
		binfo = NameAndAddressType.new(bill_to_fn, bill_to_ln)
		RAILS_DEFAULT_LOGGER.info("Authorize.Net Subscription cc fn = #{binfo.firstName} cc ln = #{binfo.lastName}")
	
		charge = @senior.group_recurring_charge
	
		aReq = ArbApi.new
		xmlout = aReq.CreateSubscription(auth,subname,schedule,charge,0, cinfo,binfo)
	
		RAILS_DEFAULT_LOGGER.info("Authorize.Net Subscription amount = #{AUTH_NET_SUBSCRIPTION_BILL_AMOUNT_PER_INTERVAL}")
	
		RAILS_DEFAULT_LOGGER.info("Authorize.Net Submitting to URL = #{AUTH_NET_URL}")
		xmlresp = HttpTransport.TransmitRequest(xmlout, AUTH_NET_URL)

		apiresp = aReq.ProcessResponse(xmlresp)
	
		RAILS_DEFAULT_LOGGER.info("\nXML Dump:" + xmlresp)

				if apiresp.success 
			session[:new_user] = nil
		   RAILS_DEFAULT_LOGGER.info("Subscription Created successfully")
		   RAILS_DEFAULT_LOGGER.info("Subscription id : " + apiresp.subscriptionid)
		else
			RAILS_DEFAULT_LOGGER.info("Subscription Creation Failed")
			apiresp.messages.each { |message| 
				RAILS_DEFAULT_LOGGER.info("Error Code=" + message.code)
				RAILS_DEFAULT_LOGGER.info("Error Message = " + message.text)
				flash[:warning] = "Unable to create subscription.  Check credit card information. Error Code=" + message.code + ", Error Message = " + message.text
			}   
			raise "Unable to create subscription."

		end
		
		@subscription = Subscription.new
		@subscription[:arb_subscriptionId] = apiresp.subscriptionid
		@subscription[:senior_user_id] = senior_user_id
		@subscription[:subscriber_user_id] = subscriber_user_id
		@subscription[:cc_last_four] = (params[:credit_card][:number]).last(4)
		@subscription[:special_notes] = params[:credit_card][:special_notes]
		@subscription[:bill_amount] = charge
		@subscription[:bill_to_first_name] = bill_to_fn
		@subscription[:bill_to_last_name] = bill_to_ln
		@subscription[:bill_start_date] = sub_start_date
		@subscription.save!
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
