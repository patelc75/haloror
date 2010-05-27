class OrdersController < ApplicationController
  # keeping RESTful
  include UserHelper
  
  def index
  	cond = ""
  	cond += "id = #{params[:id]}" if params[:id]
    @orders = Order.paginate :page => params[:page],:order => 'created_at desc',:per_page => 20,:conditions => cond
  end
  
  def new
    @groups = Group.for_user(current_user)
    @confirmation = false
    @product = session[:product]
    @order = Order.new(session[:order]) # recall if any order data was remembered
    @complete_tariff = DeviceModel.complete_tariff(params[:coupon_code])
    @clip_tariff = DeviceModel.clip_tariff(params[:coupon_code])
    
    if request.post? # confirmation mode
      @product = params[:product]
      order_params = params[:order] # we need to remember these
      
      @order = Order.new(order_params) # the rendering does not loop another time. we need @order set here
      if @product.blank?
        @order.errors.add_to_base "Please select a product to order" if session[:product].blank?
        
      else
        order_params.merge!(
            "cost" => (@product == 'complete' ? \
              DeviceModel.complete_tariff(@order.coupon_code).upfront_charge.to_s : \
              DeviceModel.clip_tariff(@order.coupon_code).upfront_charge.to_s),
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
          if DeviceModel.find_complete_or_clip(params[:product]).blank?

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
      @complete_tariff = DeviceModel.complete_tariff(@order.coupon_code)
      @clip_tariff = DeviceModel.clip_tariff(@order.coupon_code)
      
    else # store mode
      # back button needs this
      @order = (session[:order].blank? ? Order.new(:coupon_code => params[:coupon_code]) : Order.new(session[:order]))
      @same_address = @order.subscribed_for_self?
      # @same_address = (session[:order].blank? ? "checked" : (session[:order][:bill_address_same] || @order.bill_address_same || @order.ship_and_bill_address_same))
    end
    
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  def kit_serial
    # render of this action will ask for kit_serial
  end
  
  def update_kit_serial
    @order = Order.find(params[:order][:id])
    
    respond_to do |format|
      if @order.save
        flash[:notice] = 'Order was successfully saved with Kit Serial Number.'
        format.html { render :action => 'success' }
      else
        flash[:notice] = 'Please provide the Kit Serial Number'
        format.html { render :action => "kit_serial" }
      end
    end
  end
  
  # create order with products, charge card for one time fee & recurring subscription
  #
  def create
    if session[:order].blank?
      redirect_to :action => 'new'
      
    else
      goto = "new"
      respond_to do |format|
        unless session[:order].blank?

          @order = Order.new(session[:order]) # pick from session, not params
          @order.assign_group("direct_to_consumer") unless logged_in? # only assign this group when public order

          if @order.valid? && @order.save! #verify_recaptcha(:model => @order, :message => "Error in reCAPTCHA verification") && @order.save
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
                  # show on browser
                  flash[:notice] = 'Thank you for your order.'
                  goto = ((@order.retailer? || @order.reseller?) ? "kit_serial" : "success")
                  reset_session # start fresh               
                end
                # @order = nil # fixes #2564. need to check through cucumber
            
              end # order
            end # revision
        
          end # save
        end # session[:order]

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
end
