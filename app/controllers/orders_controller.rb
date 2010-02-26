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
    
    if request.post? # confirmation mode
      @product = params[:product]
      session[:order] = params[:order].merge(
          "cost" => "#{@product == 'complete' ? '439.00' : '409.00'}",
          "product" => @product
          )
      @same_address = (params[:order][:bill_address_same] == "1" ? "checked" : "")
      session[:product] = @product # same as params[:product]. Will be used later in create
      @order = Order.new(session[:order])
      #
      # check some validation on the first page itself
      # TODO: send an email to administrator or webmaster
      @order.errors.add_to_base "Link to product catalog is broken. Please inform webmaster @ halomonitoring.com about this" \
        if DeviceModel.find_complete_or_clip(params[:product]).blank?
      #
      # get to confirmation mode only when no validation errors
      @confirmation = @order.errors.count.zero? # simpler than checking session[:order]
      
    else # store mode
      # back button needs this
      @same_address ||= (session[:order].blank? ? "checked" : session[:order][:bill_address_same])
      @order ||= (session[:order].blank? ? Order.new : Order.new(session[:order]))
    end
    
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  def create
    if session[:order].blank?
      redirect_to :action => 'new'
      
    else
      goto = "new"
      respond_to do |format|
        unless session[:order].blank?
      
          @order = Order.new(session[:order]) # pick from session, not params
          @order.populate_billing_address
          @order.assign_group("direct_to_consumer")

          if @order.valid? && @order.save! #verify_recaptcha(:model => @order, :message => "Error in reCAPTCHA verification") && @order.save
            # pick any of these hard coded values for now. This will change to device_revisions on order screen
            #
            product = session[:product] # used at many places in this code
            device_model = DeviceModel.find_complete_or_clip(product) # finds clip or complete. default == complete
            if device_model.blank?
              #
              # this should have been caught on first page though
              @order.errors.add_to_base "Link to product catalog is broken. Please inform webmaster @ halomonitoring.com about this"
              
            else
              @order.order_items.create!(:device_model_id => device_model.id, :cost => @order.cost, :quantity => 1)
              static_cost = {"clip" => 49, "complete" => 59}
              @order.order_items.create!( :cost => static_cost[product], :quantity => 1, :recurring_monthly => true) if static_cost.has_key?(product)
          
              Order.transaction do
                charges = (product == "complete" ? [43900, 5900] : [40900, 4900])
                @one_time_fee, @subscription = @order.charge_one_time_and_subscription(charges[0], charges[1])
                success = (@one_time_fee.success? && @subscription.success?) unless (@one_time_fee.blank? || @subscription.blank?)
            
                if success.blank? || !success
                  goto = "failure"
                  # format.html { render :action => 'failure' }
                else
                  [@order.ship_email, @order.bill_email].each do |email|
                    UserMailer.deliver_signup_installation(email,:exclude_senior_info)
                  end
                  [@order.bill_email, "senior_signup@halomonitoring.com"].each do |email|
                    UserMailer.deliver_order_summary(@order, email, (email.include?("senior_signup") ? :no_email_log : nil))
                  end
                  flash[:notice] = 'Thank you for your order.'
                  goto = "success"
                end
                reset_session # start fresh
                # @order = nil # fixes #2564. need to check through cucumber
            
              end # order
            end # revision
        
          end # save
        end # session[:order]

        if @order.errors.count.zero?
          format.html { render :action => goto }
        else
          redirect_to :action => 'new'
        end
      end
    end # redirect_to new
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
