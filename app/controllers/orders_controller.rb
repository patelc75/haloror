class OrdersController < ApplicationController
  # keeping RESTful
  include UserHelper
  
  def new
    @confirmation = false
    @product = ""
    @same_address = "checked"
    
    if request.post? # confirmation mode
      @confirmation = true # simpler than checking session[:order]
      @product = params[:product]
      temp_order = params[:order].merge(
          "cost" => "#{@product == 'complete' ? '439.00' : '409.00'}"
          )
      @same_address = (params["billing"]["same_as_shipping"] == "1" ? "checked" : "")
      session[:order] = temp_order
      session[:product] = @product # same as params[:product]. Will be used later in create
      @order = Order.new(session[:order])
      
    else # store mode
      session[:order] = nil # fresh start
      @order = Order.new
    end
    
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  def create
    @order = Order.new(session[:order]) # pick from session, not params

    respond_to do |format|
      if @order.save
        # pick any of these hard coded values for now. This will change to device_revisions on order screen
        #
        device_name = (session[:product] == "complete") ? "Chest Strap, Halo Complete" : "Belt Clip, Halo Clip"
        device_revision = DeviceRevision.find_by_device_names(device_name)
        unless device_revision.blank?
          @order.order_items.create!(:device_revision_id => device_revision.id, :cost => @order.cost, :quantity => 1)

          Order.transaction do
            add_caregiver = "0" # if "1", we need caregiver profile. anything else, profile = nil
            @group = Group.find_or_create_by_name("direct_to_consumer")
            populate_user(nil, @order.bill_email, @group) # TODO: method should assume default values instead of blanks
            @user = User.find_by_email(@order.bill_email)
            
            # force save profile with first name and last name
            # => required in credit card processing
            Profile.generate_for_online_customer(:user => @user, :first_name => @order.bill_first_name, :last_name => @order.bill_last_name)

            unless @user.blank?
              same_as_senior = (@order.halouser ? "1" : "0")
              senior_user_id = @user.id
              populate_subscriber(@user.id.to_s,same_as_senior,add_caregiver,@user.email,profile)
              
              @one_time_fee = @order.charge_one_time_fee # variables used in failure if that happens
              if @one_time_fee.success?
                @subscription = @order.charge_subscription
                success = @subscription.success?
              end
            end
            
            if success.blank?
              format.html { render :action => 'failure' }
            else
              flash[:notice] = 'Thank you for your order.'
              format.html { render :action => 'success' }
              UserMailer.deliver_order_summary(@user) unless @user.blank?
            end
          end
        end
      else
        format.html { render :action => "new" }
      end

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
end
