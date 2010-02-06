class OrdersController < ApplicationController
  # keeping RESTful
  include UserHelper
  
  def index
  	cond = ""
  	cond += "id = #{params[:id]}" if params[:id]
    @orders = Order.paginate :page => params[:page],:order => 'created_at desc',:per_page => 20,:conditions => cond
  end
  
  def new
    @confirmation = false
    @product = ""
    @same_address = "checked"
    
    if request.post? # confirmation mode
      @confirmation = true # simpler than checking session[:order]
      @product = params[:product]
      temp_order = params[:order].merge(
          "cost" => "#{@product == 'complete' ? '439.00' : '409.00'}",
          "product" => params[:product]
          )
      @same_address = (temp_order[:bill_address_same] == "1" ? "checked" : "")
      session[:order] = temp_order
      session[:product] = @product # same as params[:product]. Will be used later in create
      # session[:card_csc] = params[:other][:card_csc] # card CSC
      # session[:bill_address_same] = params[:billing][:same_as_shipping]
      @order = Order.new(session[:order])
      
    else # store mode
      @order ||= (session[:order].blank? ? Order.new : Order.new(session[:order]))
    end
    
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  def create
    goto = "new"
    respond_to do |format|
      unless session[:order].blank?
      
      @order = Order.new(session[:order]) # pick from session, not params
      if @order.bill_address_same == "1"
        @order.bill_first_name = @order.ship_first_name
        @order.bill_last_name = @order.ship_last_name
        @order.bill_address = @order.ship_address
        @order.bill_city = @order.ship_city
        @order.bill_state = @order.ship_state
        @order.bill_zip = @order.ship_zip
        @order.bill_email = @order.ship_email
        @order.bill_phone = @order.ship_phone
      end
      @group = Group.find_or_create_by_name("direct_to_consumer")
      @order.group_id = @group.id if !@group.nil?

      # verify re-CAPTCHA and save order
      #
      if @order.save #verify_recaptcha(:model => @order, :message => "Error in reCAPTCHA verification") && @order.save
        # pick any of these hard coded values for now. This will change to device_revisions on order screen
        #
        device_name = (session[:product] == "complete") ? "Chest Strap, Halo Complete" : "Belt Clip, Halo Clip"
        device_revision = DeviceRevision.find_by_device_names(device_name)
        unless device_revision.blank?
          @order.order_items.create!(:device_revision_id => device_revision.id, :cost => @order.cost, :quantity => 1)
          if session[:product] == "clip"
            @order.order_items.create!(:cost => 49, :quantity => 1, :recurring_monthly => true)
          elsif session[:product] == "complete"
            @order.order_items.create!(:cost => 59, :quantity => 1, :recurring_monthly => true)              
          end
          
          Order.transaction do
            @one_time_fee = @order.charge_one_time_fee # variables used in failure if that happens
            if !@one_time_fee.blank? && @one_time_fee.success?
              @subscription = @order.charge_subscription(session[:product] == "complete" ? 5900 : 4900) # cents
              success = @subscription.success? unless @subscription.blank? # ramonrails: true = incorrect logic. subscription can fail for some gateway reason
            end
            
            if success.blank? || !success
              goto = "failure"
              # format.html { render :action => 'failure' }
            else
              UserMailer.deliver_signup_installation(@order.ship_email,:exclude_senior_info)   
              UserMailer.deliver_signup_installation(@order.bill_email,:exclude_senior_info)
              UserMailer.deliver_order_summary(@order, @order.bill_email) #goes to @order.bill_email
              UserMailer.deliver_order_summary(@order, "senior_signup@halomonitoring.com", :no_email_log) #do not send to email_log@halo
              reset_session # start fresh
              @order = nil
              flash[:notice] = 'Thank you for your order.'
              goto = "success"
              # format.html { render :action => 'success' }
            end
            
          end # order
        end # revision
        
      end # save
      end # session[:order]
      
      format.html { render :action => goto }
    end
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
