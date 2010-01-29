class OrdersController < ApplicationController
  # keeping RESTful
  
  # def index
  #   redirect_to 'new' unless request.post?
  # end
  
  def new
    @confirmation = false
    @product = ""
    
    if request.post? # confirmation mode
      @confirmation = true # simpler than checking session[:order]
      @product = params[:product]
      session[:order] = params[:order].merge(
          "number" => "#{Time.now.to_i.to_s}-#{rand(99999).to_s}", 
          "cost" => "#{@product == 'halo_complete' ? '439.00' : '409.00'}"
          )
      @order = Order.new(params[:order])
      
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

        Order.transaction do
          @group = Group.find_or_create_by_name("direct_to_consumer")
          @user = User.create!(
            :login => @order.name.downcase.gsub(' ',''),
            :password => 'changeme',
            :password_confirmation => 'chamgeme',
            :email => @order.bill_email
            )
          same_as_senior = (@order.halouser ? "1", "0")
          senior_user_id = @user.id
          add_caregiver = "1"
          profile = nil # ?? data fields are not received in the order form! how to create profile?
          populate_subscriber(@user,same_as_senior,add_caregiver,@user.email,profile)  
          Subscription.credit_card_validate(senior_user_id,@user.id,@user,@order.card_number,flash)             
        end
        UserMailer.deliver_order_summary(@user)
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
