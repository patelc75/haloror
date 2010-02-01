class OrdersController < ApplicationController
  # keeping RESTful
  
  def new
    @confirmation = false
    @product = ""
    @same_address = "checked"
    
    if request.post? # confirmation mode
      @confirmation = true # simpler than checking session[:order]
      @product = params[:product]
      temp_order = params[:order].merge(
          "number" => "#{Time.now.to_i.to_s}-#{rand(99999).to_s}", 
          "cost" => "#{@product == 'complete' ? '439.00' : '409.00'}"
          )
      @same_address = (params["billing"]["same_as_shipping"] == "1" ? "checked" : "")
      session[:order] = temp_order
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
    debugger

    respond_to do |format|
      if @order.save
        # ?? how to identify device from the list?
        @order.order_items.create!(:device_revision_id => DeviceRevision.last.id, :cost => @order.cost, :quantity => 1)
        flash[:notice] = 'Thank you for your order.'
        format.html { redirect_to(:controller => 'orders', :action => 'show', :id => @order) }

        # Order.transaction do
        #   @group = Group.find_or_create_by_name("direct_to_consumer")
        #   # UserHelper::populate_user
        #   @user = User.create!(
        #     :login => @order.bill_name.downcase.gsub(' ',''),
        #     :password => 'changeme',
        #     :password_confirmation => 'changeme',
        #     :email => @order.bill_email
        #     )
        #   same_as_senior = "1" # (@order.halouser ? "1", "0")
        #   senior_user_id = @user.id
        #   add_caregiver = "0" # if "1", we need caregiver profile. anything else, profile = nil
        #   profile = nil # ?? data fields are not received in the order form! how to create profile?
        #   populate_subscriber(@user,same_as_senior,add_caregiver,@user.email,profile)  
        #   Subscription.credit_card_validate(senior_user_id,@user.id,@user,@order.card_number,flash)             
        # end
        # UserMailer.deliver_order_summary(@user)
      else
        format.html { render :action => "new" }
      end
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
