class CallOrdersController < ApplicationController
  # GET /call_orders
  # GET /call_orders.xml
  def index
    @call_orders = CallOrder.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @call_orders.to_xml }
    end
  end

  # GET /call_orders/1
  # GET /call_orders/1.xml
  def show
    @call_order = CallOrder.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @call_order.to_xml }
    end
  end

  # GET /call_orders/new
  def new
    @call_order = CallOrder.new
  end

  # GET /call_orders/1;edit
  def edit
    @call_order = CallOrder.find(params[:id])
  end

  # POST /call_orders
  # POST /call_orders.xml
  def create
    @call_order = CallOrder.new(params[:call_order])

    respond_to do |format|
      if @call_order.save
        flash[:notice] = 'CallOrder was successfully created.'
        format.html { redirect_to call_order_url(@call_order) }
        format.xml  { head :created, :location => call_order_url(@call_order) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @call_order.errors.to_xml }
      end
    end
  end

  # PUT /call_orders/1
  # PUT /call_orders/1.xml
  def update
    @call_order = CallOrder.find(params[:id])

    respond_to do |format|
      if @call_order.update_attributes(params[:call_order])
        flash[:notice] = 'CallOrder was successfully updated.'
        format.html { redirect_to call_order_url(@call_order) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @call_order.errors.to_xml }
      end
    end
  end

  # DELETE /call_orders/1
  # DELETE /call_orders/1.xml
  def destroy
    @call_order = CallOrder.find(params[:id])
    @call_order.destroy

    respond_to do |format|
      format.html { redirect_to call_orders_url }
      format.xml  { head :ok }
    end
  end
end
