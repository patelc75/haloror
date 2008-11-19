class AtpController < ApplicationController
  
  def work_orders
    @work_orders = WorkOrder.find(:all, :order => 'work_order_num asc', :include => [:device_types_work_orders, :device_types])
  end
  
  def work_order_view
    if !params[:id].blank?
      @work_order = WorkOrder.find(params[:id], :include => [:device_types_work_orders, :device_types])
    else
      redirect_to :controller => 'atp', :action => 'work_orders'
    end   
  end
  
  def work_order_init
    @work_order = WorkOrder.new
    @device_types = DeviceType.find(:all, :order => "device_type desc", :include => {:device_models => :device_revisions})
  end
  
  def work_order_save
    work_order_num = params[:work_order][:work_order_num]
    if !work_order_num.blank?
      @work_order = WorkOrder.create(:work_order_num => work_order_num)
    else
      @work_order = WorkOrder.create
      @work_order.work_order_num = @work_order.id
      @work_order.save!
    end   
    redirect_to :controller => 'atp', :action => 'work_order_device_type_init', :work_order_id => @work_order.id
  end
  
  def work_order_device_type_init
    @work_order = WorkOrder.find(params[:work_order_id])
    @device_types = DeviceType.find(:all, :order => 'device_type desc')
  end
  
  def work_order_device_type_save
    @work_order = WorkOrder.find(params[:work_order_id])
    if !params[:device_type][:id].blank? || !params[:num].blank?
      @device_type = DeviceType.find(params[:device_type][:id])
      @work_order.device_types << @device_type
      @device_types_work_order = @work_order.device_types_work_orders.find(:first, :conditions => "device_type_id = #{@device_type.id}")
      @device_types_work_order.num = params[:num]
      @device_types_work_order.starting_serial_num = params[:starting_serial_num] if params[:starting_serial_number]
      @device_types_work_order.save!
      redirect_to :controller => 'atp', :action => 'work_orders'
    else
      flash[:warning] = 'Device Type and Number Of Devices are Required.'
      @device_types = DeviceType.find(:all, :order => 'model desc')
      render :action => 'work_order_device_type_init'
    end
  end
end