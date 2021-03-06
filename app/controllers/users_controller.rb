class UsersController < ApplicationController  
  before_filter :authenticated?, :except => [:init_user, :update]
  before_filter :authenticate_admin?, :only => [:triage] # admin and super_admin can see triage
  
  require 'user_helper'
  include UserHelper

  # def index
  #   @users = current_user.group_memberships.collect(&:users)
  #   respond_to do |format|
  #     format.html
  #     format.xml { render :xml => @users }
  #   end
  # end
  
  # 
  #  Tue Dec 21 23:35:56 IST 2010, ramonrails
  #   * DRYed
  def cancel_account
    # @user = User.find(params[:id])
    # @user.cancel_account unless @user.blank?
    @user.cancel_account if ( @user = User.find(params[:id]) )
  end

  def triage
    @groups = current_user.groups_where_admin
    @params = params
    # params include name of selected group as search_group
    @users = current_user.triage_users( params).paginate :per_page => 7, :page => params[:page]
    respond_to do |format|
      format.html
    end
  end
  
  def toggle_test_mode
    @user = User.find(params[:id])
    if request.post?
      @user.toggle_test_mode
      flash[:message] = "#{@user.name} is now in #{@user.test_mode? ? 'Test' : 'Normal'} mode."
    else
      flash[:message] = "Status not changed for #{@user.name}"
    end
    #render :action => 'special_status' # @user variable already loaded
    #redirect_to :action => 'users'
  end
  
  def special_status
    @user = User.find(params[:id])
    respond_to do |format|
      format.html
    end
  end

  # dismiss users from triage
  # Usage: POST
  #   dismiss( ["all" | "selected" | "abnormal" | "normal" | "caution" | "test mode"], [1, 2, 3])
  # WARNING: Tue Aug 17 22:26:25 IST 2010 this should now be shifted to User::STATUS logic
  def dismiss
    what = params[:commit].downcase
    unless what.blank?
      # check boxes are "selected" set. All of them are hidden "users" set
      # we are saving query + complexity here by just fetching this data from submitted form
      # nested HTML forms are not supported, anyways
      users = ( (what == "selected") ? (params[:selected] ? params[:selected].keys.collect(&:to_i) : []) : params[:users].collect(&:to_i) )
      current_user.dismiss_batch( what, users) unless users.blank?
    end
    redirect_to :back # go back, where came from
  end
  
  # TODO: this should ideally be a POST call. It is changing the state of data
  def dismiss_all_greens
    current_user.dismiss_all_greens_in_triage
    respond_to do |format|
      format.html { redirect_to :action => 'triage' }
    end
  end
  
  # def dismiss
  #   @user = params[:user_id]
  #   @dismiss = "1"
  #   @back_url = params[:back_url]
  #   
  #   respond_to do |format|
  #     format.html
  #   end
  # end
  # 
  # def undismiss
  #   @user = params[:user_id]
  #   @dismiss = "0"
  #   @back_url = params[:back_url]
  #   
  #   respond_to do |format|
  #     format.html
  #   end
  # end
  # 
  # # update dismiss or undismiss
  # def update_dismiss
  #   user = User.find(params[:user_id])
  #   dismiss = params[:dismiss]
  #   back_url = params[:back_url]
  # end
  
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
    if params.has_key?( 'user_id')
      RAILS_DEFAULT_LOGGER.debug("****START show")
      if params[:user_id]
        @senior_user = User.find(params[:user_id])
      end
      @user = User.new
      @profile = Profile.new
      render :action => 'credit_card_authorization' # QUESTION: even for admin account?

    else
      @user = User.find( params[:id])
      # render 'show' action
    end
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
  
  # 
  #  Fri Nov 12 18:02:44 IST 2010, ramonrails
  #  DEPRECATED: to avoid confusion in code
  #
  # #handles 3 scanerios (1) new subscriber (1)subscriber same as senior (2)new subscriber also caregiver
  # # QUESITON: Can we deprecate this?
  # #   * Used by credit_card_authorization.html.erb
  # def create_subscriber
  #   senior_user_id = params[:user_id]
  #   @senior = User.find senior_user_id
  #   if !request.post?  #clicking "skip" is a GET (vs a POST)
  #     #@user = User.find(params[:user_id])
  #   else
  #     User.transaction do
  #       same_as_senior = params[:users][:same_as_senior]
  #       add_caregiver = params[:users][:add_caregiver] 
  #       populate_subscriber(params[:user_id],same_as_senior,add_caregiver,params[:email],params[:profile])  
  # 
  #       #Credit Card auth needs to be in a transaction so subscriber/caregiver data can be rolled back
  # 
  #       Subscription.credit_card_validate(senior_user_id,@user.id,@user,params[:credit_card],flash)             
  #     end
  #     #this following does not need to be in the transaction because the lines above this do not need to be rolled back if the below lines fail
  #     # role = @user.has_role 'subscriber', halouser #@user set up in populate_caregiver when subscriber is also a caregiver
  #     UserMailer.deliver_order_receipt(@user)
  #     # Mon Nov  1 22:27:56 IST 2010
  #     #   This might send duplicate emails
  #     #   The email logic is now in user model
  #     UserMailer.deliver_signup_installation(@user,@senior) # @user = subscriber
  #   end
  #   #=begin
  # rescue Exception => e
  #   RAILS_DEFAULT_LOGGER.warn("ERROR in create_subscriber, #{e}")
  #   RAILS_DEFAULT_LOGGER.debug(e.backtrace.join("\n"))
  #   if request.post?
  #     @senior_user = @senior
  #     render :action => 'credit_card_authorization'
  #   else
  #     @senior = User.find(params[:id])
  #   end
  #   #=end    
  # end

  def add_kit_number(kit_serial_number,user)
    if (kit_serial_number == nil || kit_serial_number.size != 10 || kit_serial_number[0,2] != 'H4' ) 
      @msg = "Invalid serial number"  
    else
      @msg = ""
    end  
    kit_device = Device.find_by_serial_number(kit_serial_number)
    if kit_device
    if kit_device.kits.first
      @kit = kit_device.kits.first
      @gw = @kit.check_for_device_type('Gateway')
      @cs = @kit.check_for_device_type('Chest Strap')
      @bc = @kit.check_for_device_type('Belt Clip')
      if @gw == false
        @msg += "<br> Not found Gateway "
      end
  
      if @cs == false && @bc == false
        @msg += "<br> Not found Chest Strap or Belt Clip "
      end
    else
      @msg = "<br> Not found Kit Id"
    end
    else
     @new_kit = KitSerialNumber.create(:serial_number => kit_serial_number,:user_id => @user.id)
    end
  end
 
  def signup_info
    
    @user = User.find(params[:user_id])
    kit_serial_number = params[:kit][:serial_number]
    @msg = ""
    
    add_kit_number(kit_serial_number,@user)
    
    error_message = @msg
    flash[:warning] = error_message
    if @msg != ""
      redirect_to "/users/create_subscriber/#{@user.id}"
    else
      if !@new_kit
        params[:gateway_serial_number] = @gw.serial_number
        params[:strap_serial_number] = @cs.serial_number if @cs != false
        params[:strap_serial_number] = @bc.serial_number if @bc != false
        map_serial_numbers
      end
      UserMailer.deliver_order_complete(@user, kit_serial_number, current_user)
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
    @group = params[:group]
    if !@group.blank? && @group != 'Choose a Group'
      User.transaction do
        populate_user(params[:profile],params[:email],@group,current_user.id,params[:opt_out_call_center])
        if @user
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
  
  def email_view
  	@user = User.find params[:id]
  end
  
  # TODO: this needs a clean-up. too many things happing here for one simple mail dispatch
  def send_caregiver_details
  	@user = User.find params[:id]
  	@user.build_profile unless @user.profile # avoid errors on form due to nil profile
  	UserMailer.deliver_senior_and_caregiver_details(@user)
  	@user.user_intakes.first.safety_care_email_sent # update the date (today) when the email was sent
  	flash[:mail_send] = "Email Sent."
  	redirect_to :action => 'email_view',:id => params[:id]
  end
  
  def add_device_to_user
    _user = User.find( params[:user_id])
    if valid_serial_number( params[:serial_number])
      register_user_with_serial_num( _user, params[:serial_number].strip)
    else
      flash[:notice] = "Not Valid Serial Number, Serial number must be exactly 10 digits."
    end 
     
    # unless params[:page] == '1'
    #   redirect_to :controller => 'reporting', :action => 'users',:page => params[:page]
    # else
    	redirect_to :controller => 'users', :action => 'show', :id => _user
    # end   
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

  def credentials
  # user reaches here for activation of account
  # /activate/<activation_code>      
    respond_to do |format|
      format.xml {render :xml => current_user.to_xml(:dasherize => false, :skip_types => true, :only => [:id, :login, :status])}
      #including profiles does not work ("odd number list for Hash")
      #format.xml {render :xml => current_user.to_xml(:dasherize => false, :skip_types => true, :only => [:id, :login, :status], :include => {:profiles})}                                   
    end                            
  end
  
  def init_user
    if ( @user = User.find_by_activation_code(params[:activation_code]) )
      # FIXME: the logic needs more coverage
      #   login prefixed with _AUTO_ was generated by user intake
      #   this is the quickest fix to minimize time and get both features to work
      #
      # users with _AUTO_ generated login can be "activated?"
      if @user.activated? && !@user.login.blank? && !@user.crypted_password.blank? && !(@user.login =~ /_AUTO_/)
        #
        # ask for login. this user is activated already
        session[:senior] = params[:senior]
        redirect_to login_path # use ***_path instead of ***_url

        # else
        # just show user's attributes on form
        # 
        #  Fri Nov 26 20:48:32 IST 2010, ramonrails
        #   * do not increment caregiver position here!
        #   * increment on "update"
        #
        # # Sat Oct  2 02:21:20 IST 2010
        # # https://redmine.corp.halomonitor.com/wiki/haloror/Dev_Testing 1.6.0 PQ
        # #   we need caregiver position only when user getting activated is a caregiver
        # if params[:senior] && @user.is_caregiver? && !@user.is_subscriber?
        #   if (senior = User.find params[:senior])
        #     role_user = senior.roles_user_by_caregiver(@user)
        #     RolesUsersOption.update(role_user.roles_users_option.id, {:active => 1,:position => User.get_max_caregiver_position(senior)}) unless role_user.blank?
        #   end
        # end

      end # activated?
    end # @user ?
  end

  # 
  #  Thu Mar 17 03:27:57 IST 2011, ramonrails
  #   * https://redmine.corp.halomonitor.com/issues/4097
  def change_password
    @user = User.find( params[:id])
  end
  
  def update
    #  check if this is an activation request or regular update
    if params[:user][:activation_code].blank?
      #
      # just a regular update
      @user = User.find(params[:id])
      # 
      #  Thu Jun  2 02:46:02 IST 2011, ramonrails
      #   * skip_validation if any of the given attributes was received in hash
      @user.skip_validation = !(params[:user].keys & ["need_validation", "password"]).blank?
      respond_to do |format|
        if @user.update_attributes!(params[:user])
          # puts "look closer"

          flash[:notice] = 'User was successfully updated.'
          format.html { redirect_to  :controller => "users", :action => "show", :id => @user } # user_url does not fit
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @user.errors.to_xml }
        end
      end

    # we reach here when user is activating its account
    #   identified by params[:user][:activation_code] in request
    else
      @user = User.find_by_activation_code(params[:user][:activation_code])

      if @user.blank?
        flash[:warning] = "Was this user already activated?"
        reset_session
        redirect_to '/'

      else
        # Fri Oct 22 02:32:01 IST 2010
        #   FIXME: we need to optimize the redirection mechanism to more appropriate common method
        #   Here should just be activation. That too, more DRY
        user_hash = params[:user]
        if user_hash[:password] == user_hash[:password_confirmation]
          if user_hash[:password].length >= 4 # FIXME: Why is validation logic duplicated here? Needs DRYing
            @user.password = user_hash[:password]
            @user.password_confirmation = user_hash[:password_confirmation]
            @user.login = user_hash[:login]
            # https://redmine.corp.halomonitor.com/issues/3554 point 3 fixed by this
            @user.skip_validation = true # this object could have been "saved" earlier
            if @user.save
              self.current_user = @user
              if logged_in? && !current_user.activated?
                current_user.activate
              end
              # 
              #  Tue Nov 30 00:49:20 IST 2010, ramonrails
              #   * https://redmine.corp.halomonitor.com/issues/3798#note-2
              #   * as discussed with Chirag
              #     when a caregiver gets its authentication credentials activated
              #     then it does not become an "active caregiver", just gets login activated
              # current_user.set_active
              #
              if current_user.is_caregiver?
                # 
                #  Fri Nov 26 20:49:23 IST 2010, ramonrails
                #   * increment caregiver position, unless already defined
                #   * QUESTION: Why should we establish caregiver position here?
                #   *   Why is that not established when user was created? Any other logic applies?
                if (_senior = @user.is_caregiver_for_what.first) # find senior
                  if (_position = @user.caregiver_position_for( _senior)) # find any existing position
                    if _position.blank? || (_position.to_i == 0) # only when position not already defined
                      #   * when next position is nil, it does not get assigned
                      #   * so, this is safe to call like this, without checking position value
                      @user.options_for_senior( _senior, { :position => _senior.next_caregiver_position } ) # SET
                    end
                  end
                end
              
                #  Wed Nov 24 18:06:36 IST 2010, ramonrails
                #   * https://redmine.corp.halomonitor.com/issues/3782
                #   * after caregiver activation, show recently activated caregiver
                #   
                # if session[:senior]
                #   redirect_to :controller => 'call_list', :action => 'show', :id => session[:senior]
                # else
                redirect_to :controller => 'call_list', :action => 'show', :recently_activated => 'true'
                # end
              
                # FIXME: patching the logic here for now. Needs DRYing up. Needs code coverage.
                # redirect to user intake, if the current_user is halouser/subscriber with incomplete user intake
              elsif (current_user.is_halouser? || current_user.is_subscriber?)
                # if this user has
                #   an incomplete user intake, sk to fill it
                #   completed user intake but legal agreement not made, ask for agreement
                if current_user.incomplete_user_intakes.blank? && current_user.legal_agreements_pending.blank?
                  # if current_user.legal_agreements_pending.blank?
                  redirect_to '/'
                else
                  # paths do not work correctly. using url_for
                  redirect_to :controller => 'user_intakes', :action => 'show', :id => current_user.user_intakes.first
                end
                #
                # do not ask edit right away. let the senior/subscriber agree to subscriber's agreement first
                # else
                #   # WARNING: subscriber can have many user intakes. How do we identify the correct one?
                #   # FIXME: For now: assuming the user just got activated, it only has one user intake
                #   # Needs to be tested yet
                #   # paths do not work correctly. using url_for
                #   redirect_to url_for(:controller => 'user_intakes', :action => 'edit', :id => current_user.incomplete_user_intakes.first)
                #   # once the user intake is submitted successfully, legal agreement will be shown automatically until agreed
                #   # any user other than halouser/subscriber will also see the legal agreement, but can only print. cannot accept/agree/submit.
                # end
            
              # Fri Oct 22 02:31:18 IST 2010
              #   TODO: DRY: This logic should be elsewhere in a common method, not here
              elsif current_user.is_admin?
                redirect_to :controller => 'reporting', :action => 'users'
              
              else
                redirect_to '/'
              end

              # 
              #  Thu Feb  3 00:16:55 IST 2011, ramonrails
              #   * https://redmine.corp.halomonitor.com/issues/4124
            else
              render :action => 'init_user'
            end

          else
            flash[:warning] = "Password must be at least 4 characters"
            render :action => 'init_user'
          end
        else
          flash[:warning]= "New Password must equal Confirm Password"
          render :action => 'init_user'
        end
      end # @user.blank?

    # rescue
    #   render :action => 'init_user'
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

  def new_caregiver_options
    load_values_to_allow_new_caregiver(params[:user_id].to_i)
    @back_url = params[:back_url]
  end
  
  
  def new_caregiver
    load_values_to_allow_new_caregiver(params[:user_id].to_i) # shifted to helper. allow use at other places
    # @senior = User.find(params[:user_id].to_i)    
    # 
    # @removed_caregivers = []
    # @senior.caregivers.each do |caregiver|
    #   if caregiver
    #     roles_user = @senior.roles_user_by_caregiver(caregiver)
    #     #caregiver.roles_users.each do |roles_user|
    #       if roles_user.roles_users_option and roles_user.roles_users_option[:removed]
    #         @removed_caregivers << caregiver
    #       end
    #     #end 
    #   end
    # end
    # 
    # @max_position = User.get_max_caregiver_position(@senior)
    # 
    # @password = random_password
    # 
    # @user = User.new 
    # @profile = Profile.new  
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

  def create_caregiver
    @back_url = params[:back_url] # non ajax
    
    User.transaction do     
      User.populate_caregiver(params[:user][:email],params[:user_id].to_i,params[:position],params[:user][:login])
    end
    
    if @back_url.blank?
      render :partial => 'caregiver_email'
    else
      redirect_to_message(:message => :new_caregiver, :back_url => @back_url)
    end
  # rescue Exception => e
  #   RAILS_DEFAULT_LOGGER.warn "#{e}"
  #   # check if email exists
  #   if existing_user = User.find_by_email(params[:user][:email])
  #     @existing_id = existing_user[:id]
  #     @add_existing = true
  #   end
  #  
  # # old code without if else
  #  #render :partial => 'caregiver_form'
  # 
  #  #new code with if else and created a new partial existing_caregiver_form and removed <% if @add_existing %> function in  caregiver_form   
  #   @max_position = User.get_max_caregiver_position(@user)
  #    if (@add_existing == true )
  #        render :partial => 'existing_caregiver_form'
  #        else
  #        render :partial => 'caregiver_form'
  #   end
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
    opt.position = user.next_caregiver_position # User.get_max_caregiver_position(user)
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
    opt.position = @patient.next_caregiver_position # User.get_max_caregiver_position(@patient)
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

  # https://redmine.corp.halomonitor.com/issues/3475
  #   Refactor UsersController:register_user_with_serial_num so you can reuse
  #
  def register_user_with_serial_num(user, serial_number)
    @device = user.add_devices_by_serial_number( serial_number)
    #
    # Sat Sep 25 03:14:36 IST 2010 Old logic
    #
    # unless device = Device.find_by_serial_number(serial_number)
    #   device = Device.new
    #   device.serial_number = serial_number
    #   # if(device.serial_number[0].chr == 'H' and device.serial_number[1].chr == '1')
    #   #         device.set_chest_strap_type
    #   #       elsif(device.serial_number[0].chr == 'H' and device.serial_number[1].chr == '2')
    #   #         device.set_gateway_type
    #   #       end
    #   device.save!
    # end
    # 
    # if device.device_type.blank?
    #   if(device.serial_number[0].chr == 'H' and device.serial_number[1].chr == '1')
    #     device.set_chest_strap_type
    #   elsif(device.serial_number[0].chr == 'H' and device.serial_number[1].chr == '2')
    #     device.set_gateway_type
    #   end   
    # end
    # device.users << user
    # device.save!
  end
    
  #  Tue Dec 21 20:52:53 IST 2010, ramonrails
  #   * block comment does not depict in global search. this does.
  # def enable_by_default(roles_user)
  #   
  #     ALERTS_ENABLED_BY_DEFAULT.each do |type|
  #       alert_type = AlertType.find_by_alert_type(type)
  #     
  #       alert_opt = AlertOption.new
  #       alert_opt.roles_user_id = roles_user.id
  #       alert_opt.alert_type_id = alert_type.id
  #       alert_opt.phone_active = true
  #       alert_opt.email_active = true
  #       alert_opt.text_active = true
  #       alert_opt.save
  #     end
  # end
  
end
