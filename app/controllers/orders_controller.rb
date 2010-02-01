class OrdersController < ApplicationController
  # keeping RESTful
  include UserHelper
  
  def index
  	@orders = Order.find(:all,:order =>'created_at desc')
  end
  
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
    unless session[:order].blank?
      @order = Order.new(session[:order]) # pick from session, not params

      respond_to do |format|
        if @order.save
          # pick any of these hard coded values for now. This will change to device_revisions on order screen
          device_name = (session[:product] == "complete") ? "Chest Strap, Halo Complete" : "Belt Clip, Halo Clip"
          device_type = DeviceType.find_product_by_any_name(device_name)
          unless device_type.blank?
            @order.order_items.create!(:device_revision_id => device_type.latest_model_revision, :cost => @order.cost, :quantity => 1)
            flash[:notice] = 'Thank you for your order.'
            format.html { redirect_to(:controller => 'orders', :action => 'show', :id => @order) }

            Order.transaction do
              add_caregiver = "0" # if "1", we need caregiver profile. anything else, profile = nil
              profile = nil # ?? data fields are not received in the order form! how to create profile?

              @group = Group.find_or_create_by_name("direct_to_consumer")
              # UserHelper::populate_user. cannot be created unless we have login & password.
              populate_user(profile, @order.bill_email, @group, nil) # TODO: method should assume default values instead of blanks
              @user = User.find_by_email(@order.bill_email)
              # @user = User.create(
              #   :login => @order.bill_name.downcase.gsub(' ',''),
              #   :password => 'changeme',
              #   :password_confirmation => 'changeme',
              #   :email => @order.bill_email
              #   )
              unless @user.blank?
                same_as_senior = (@order.halouser ? "1" : "0")
                senior_user_id = @user.id
                populate_subscriber(@user,same_as_senior,add_caregiver,@user.email,profile)  
                Subscription.credit_card_validate(senior_user_id,@user.id,@user,@order.card_number,flash)             
              end
            end
            UserMailer.deliver_order_summary(@user) unless @user.blank?
          end
        else
          format.html { render :action => "new" }
        end
        
        # clear off session data to avoid multiple submits on reload
        #
        session[:order] = nil
        session[:product] = nil
      end # redirect or save      
    end
  end
  
  def show
    @order = Order.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      # format.xml  { render :xml => @order }
    end
  end
    
end
