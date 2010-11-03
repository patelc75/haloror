class OrdersController < ApplicationController
  before_filter :group_selected?, :only => :new
  
  # keeping RESTful
  include UserHelper
  
  def index
  	cond = ""
  	cond += "id = #{params[:id]}" if params[:id]
    @orders = Order.paginate :page => params[:page],:order => 'created_at desc',:per_page => 20,:conditions => cond
  end
  
  def new
    #
    # https://redmine.corp.halomonitor.com/issues/3335
    # there always is a group applicable to user
    # Tue Nov  2 04:24:51 IST 2010
    #   https://redmine.corp.halomonitor.com/issues/3653#note-7
    @groups = (logged_in? ? Group.for_user(current_user) : [Group.direct_to_consumer])
    @confirmation = false
    @product = session[:product]
    @order = Order.new(session[:order]) # recall if any order data was remembered
    @order.group = Group.find_by_id( session[:order_group_id].to_i) if @order.group.blank? # assigned by before_filter
    @complete_tariff = DeviceModel.complete_coupon( @order.group, params[:coupon_code])
    @clip_tariff = DeviceModel.clip_coupon( @order.group, params[:coupon_code])
    
    if request.post? # confirmation mode
      @product = params[:product]
      order_params = params[:order] # we need to remember these
      
      @order = Order.new(order_params) # the rendering does not loop another time. we need @order set here
      @order.group = Group.find_by_id( session[:order_group_id].to_i) if @order.group.blank? # assigned by before_filter
      # debugger
      if @product.blank?
        @order.errors.add_to_base "Please select a product to order" if session[:product].blank?
        
      else
        # https://redmine.corp.halomonitor.com/issues/3653#note-7
        # already assigned above
        # @order.group = Group.find( session[:order_group_id]) # @groups.first if @order.group.blank?
        #
        # TODO: order_params need some cleanup. Revisit when appropriate.
        #   This can probably be obsolete and attributes can go directly to session[:order]
        order_params.merge!(
            "cost" => (@product == 'complete' ? \
              DeviceModel.complete_coupon(@order.group, @order.coupon_code).upfront_charge.to_s : \
              DeviceModel.clip_coupon(@order.group, @order.coupon_code).upfront_charge.to_s),
            "product" => @product
            )
        session[:product] = @product # same as params[:product]. Will be used later in create
        #
        # any flash messages for invalid or expired coupon code
        message = @order.message_for_coupon_code(@order.coupon_code, @product)
        flash[:warning] = message unless message.blank?
        #
        # check some validation on the first page itself
        # TODO: send an email to administrator or webmaster
        @order.errors.add_to_base \
          "Link to product catalog is broken. Please inform webmaster @ halomonitoring.com about this" \
          if DeviceModel.find_complete_or_clip( params[:product] ).blank?

      end
      @same_address = @order.subscribed_for_self?
      # @same_address = ((params[:order][:bill_address_same] == "1" || @order.ship_and_bill_address_same) ? "checked" : "")
      session[:order] = order_params
      #
      # get to confirmation mode only when no validation errors
      # validations must pass before confirmation page
      # https://redmine.corp.halomonitor.com/issues/2718
      @confirmation = (@order.errors.count.zero? && !@product.blank? && !session[:order].blank?)
      #
      # https://redmine.corp.halomonitor.com/issues/2764
      complete_temp = DeviceModel.complete_coupon(@order.group, @order.coupon_code)
      clip_temp = DeviceModel.clip_coupon(@order.group, @order.coupon_code)
      @complete_tariff = complete_temp unless complete_temp.blank?
      @clip_tariff = clip_temp unless clip_temp.blank?
      
    else # store mode
      # back button needs this
      @order = (session[:order].blank? ? Order.new(:coupon_code => params[:coupon_code], :created_by => current_user, :updated_by => current_user) : Order.new(session[:order]))
      @order.group = Group.find_by_id( session[:order_group_id].to_i) if @order.group.blank? # assigned by before_filter
      @same_address = @order.subscribed_for_self?
      # @same_address = (session[:order].blank? ? "checked" : (session[:order][:bill_address_same] || @order.bill_address_same || @order.ship_and_bill_address_same))
    end

    # Fri Oct 29 05:34:34 IST 2010
    # WARNING: switched off for sometime. migraton must be run on servers
    # # Thu Oct 28 07:03:01 IST 2010
    # #   if we do not have default coupon codes, we need to migrate the database
    # #   without these, the online store might crash
    # if Group.has_default_coupon_codes?
      #
      # usually, this block executes
      respond_to do |format|
        format.html # new.html.erb
      end
    # else
    #   # Thu Oct 28 07:04:47 IST 2010
    #   #   we should never reach here, but if we did;
    #   #   * something is seriously wrong with the database
    #   #   * the data is lost accidentally?
    #   #
    #   # send some email to admin or super admin?
    #   redirect_to :action => "store_failure"
    # end
  end

  # selects and assigns the group into session
  def select_group
    @groups = Group.for_user( current_user) # QUESTION: can we use user.group_memberships ?

    # POST: select the group, redirect back to calling action
    if request.post?
      group = Group.find( params[:group_id])
      if group.blank?
        flash[:notice] = "Selecting a group is mandatory before placing the order"
      else
        session[:order_group_id] = group.id
        redirect_to :controller => 'orders', :action => 'new'
        flash[:notice] = "Placing order within group #{group.name}..."
      end
      # otherwise, keep asking to select a group
    
    # GET: show selection page
    else
      respond_to do |format|
        format.html # render page to select group
      end
    end
  end

  # Wed Nov  3 03:21:52 IST 2010, ramonrails
  #   only allow switching when enough groups available
  def switch_group
    #
    # check how many grops are available
    _groups = Group.for_user( current_user)
    #
    # single? just select it and get back to order
    if _groups.length == 1
      session[:order_group_id] = _groups.first.id
      redirect_to :controller => 'orders', :action => 'new'
    #
    # we do have many, allow user to select
    else
      session[:order_group_id] = nil
      store_location
      redirect_to :controller => 'orders', :action => "select_group"
    end
  end

  def kit_serial
    # render of this action will ask for kit_serial
  end
  
  def update_kit_serial
    @order = Order.find(params[:order][:id])
    @order.kit_serial = params[:order][:kit_serial]
    
    if @order.save # && !@order.need_to_force_kit_serial?
      # when the business logic reaches here for kit_serial, include agreement logic
      flash[:notice] = "Order was #{ params[:commit] == 'Skip' ? 'processed without' : 'successfully saved with' } Kit Serial Number."
      @user_intake = @order.user_intake
      # Tue Nov  2 06:50:59 IST 2010
      #   logic was updated to just show a successful order
      #   senior/subscriber will sign the agreement later from email links
      action = 'success' # (@order.need_agreement_sign? ? 'agreement' : 'success')
    else
      flash[:notice] = 'Please provide the Kit Serial Number'
      action = 'kit_serial'
    end
    
    respond_to do |format|
      format.html { render :action => action }
    end
  end
  
  # create order with products, charge card for one time fee & recurring subscription
  #
  def create
    # debugger
    @groups = (logged_in? ? Group.for_user(current_user) : [Group.direct_to_consumer])
    if session[:order].blank?
      redirect_to :action => 'new'
      
    else
      goto = "new"
      unless session[:order].blank?

        @order = Order.new(session[:order]) # pick from session, not params
        @order.group = Group.find_by_id( session[:order_group_id].to_i) if @order.group.blank? # assigned by before_filter
        # @order.group = Group.direct_to_consumer unless logged_in? # only assign this group when public order

        if @order.valid? && @order.save #verify_recaptcha(:model => @order, :message => "Error in reCAPTCHA verification") && @order.save
          # pick any of these hard coded values for now. This will change to device_revisions on order screen
          @order.product = session[:product] # used at many places in this code
          
          if @order.product_from_catalog.blank?
            # this should have been caught on first page though
            @order.errors.add_to_base "Link to product catalog is broken. Please inform webmaster @ halomonitoring.com about this"
            
          else
            # create order_items. @order has everything in it to create these
            @order.create_order_items
            
            Order.transaction do
              # we process the card in cents, but the tariff is USD
              # @one_time_fee, @subscription = @order.charge_credit_card
              # success = (@one_time_fee.success? && @subscription.success?) \
              #   unless (@one_time_fee.blank? || @subscription.blank?)
              success = @order.charge_credit_card # more DRY now. within Order instance
              
              if success.blank? || !success
                goto = "failure"
                # format.html { render :action => 'failure' }
              else
                # success
                #
                # # CHANGED: emails are now delivered explicitly through order > create_user_intake > dispatch_emails
                # # https://redmine.corp.halomonitor.com/issues/3067
                #
                # CHANGED: No need to deliver here now. Order does that automatically through user intake
                #
                # deliver emails
                # emails = []
                # emails << @order.ship_email
                # emails << @order.bill_email unless @order.ship_and_bill_address_match
                # emails.each do |email|
                #   UserMailer.deliver_signup_installation(email,:exclude_senior_info)
                # end
                [@order.bill_email, "senior_signup@halomonitoring.com"].each do |email|
                  UserMailer.deliver_order_summary(@order, email, (email.include?("senior_signup") ? :no_email_log : nil))
                end
                
                # Thu Oct 28 23:56:18 IST 2010
                #   CHANGED: DRYed into order and group model
                @order.send_summary_to_master_group
                # if (!@order.group.name.blank?)   #old matching code: !(o.group.name.match /^ml_/).nil?
                #    master_group = Group.find_by_name(@order.group.name[0..2] + 'master')  #eg. find ml_master group
                #    if !master_group.nil? and !master_group.email.blank? 
                #      UserMailer.deliver_order_summary(@order, master_group.email) 
                #    end
                # end 
                                    
                # show on browser
                flash[:notice] = 'Thank you for your order.'
                # https://redmine.corp.halomonitor.com/issues/2901
                # user must see agreement before the success page
                @user_intake = @order.user_intake
                @redirect_hash = {:controller => 'orders', :action => 'success', :id => @order.id} # if the user prints agreement, we need this
                #
                # revisit during 1.7.0
                # ref: google doc "billing" sheet
                #   show kit_serial page only to retailers. nobody else sees it.
                goto = ( @order.retailer? ? "kit_serial" : 'success' ) # (@order.user_intake.paper_copy_submitted? ? 'success' : 'agreement'))
                #
                # WARNING: do not reset the session. just clear the variables that are no more required
                # # reset_session # start fresh
                [:order, :product].each {|e| session[e] = nil } # just remove order related stuff from session
              end
              # @order = nil # fixes #2564. need to check through cucumber
          
            end # order
          end # revision
      
        else
          # valid? or save will put errors in @order object
          flash[:notice] = "Order may be missing some required information. Please check."
          goto = "new"
        end # save
      end # session[:order]
      
      respond_to do |format|
        format.html { render :action => goto }
      end
    end # redirect_to new
  end
  
  def show
    @order = Order.find(params[:id])
  end
  
  def success
    @order = Order.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
    end
  end
  
  def failure
    respond_to do |format|
      format.html # show.html.erb
    end
  end
  
  def comments
  	@order = Order.find_by_id(params[:order_id])
  end
  
  def agreement
    @order = Order.find_by_id(params[:order_id])
    @user_intake = @order.user_intake # should have been created in "save" mode

    respond_to do |format|
      format.html
    end
  end
  
  # =========================================
  # = private only. no rendering or calling =
  # =========================================
  
  private
  
  def group_selected?
    if logged_in?
      if session[:order_group_id].blank? # no group selected?

        groups = Group.for_user( current_user) # check applicable groups
        if groups.length == 1 # just one group? select it
          session[:order_group_id] = groups.first.id
          
        else # more than one group for user? ask to select
          respond_to do |format|
            format.html do
              store_location # remember wher we came from
              redirect_to :controller => 'orders', :action => 'select_group' # ask the group
            end
          end
        end

      end
    else # public user?
      session[:order_group_id] = Group.direct_to_consumer.id
    end # logged_in? or public user?
    true # if we reach here, we have group in session
  end

end
