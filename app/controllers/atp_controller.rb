class AtpController < ApplicationController
  
  def work_orders
    @work_orders = WorkOrder.find(:all, :order => 'work_order_num asc', :include => [{:device_revisions_work_orders => 
                                                                                      {:device_revision => 
                                                                                        [{:device_model => :device_type}]}}])
  end
  
  def work_order_view
    if !params[:id].blank?
      @work_order = WorkOrder.find(params[:id], :include => [{:device_revisions_work_orders => 
                                                              {:device_revision => 
                                                                [{:device_model => :device_type}]}}])
    else
      redirect_to :controller => 'atp', :action => 'work_orders'
    end   
  end
  
  def work_order_init
    @work_order = WorkOrder.new
    @device_revisions = DeviceRevision.find(:all, :order => "revision desc", :include => {:device_model => :device_type})
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
    redirect_to :controller => 'atp', :action => 'work_order_device_revision_init', :work_order_id => @work_order.id
  end
  
  def work_order_device_revision_init
    @work_order = WorkOrder.find(params[:work_order_id])
    @device_revisions = DeviceRevision.find(:all, :order => "revision desc", :include => {:device_model => :device_type})
  end
  
  def work_order_device_revision_save
    @work_order = WorkOrder.find(params[:work_order_id])
    if !params[:device_revision][:id].blank?
      @device_revision = DeviceRevision.find(params[:device_revision][:id])
      @work_order.device_revisions << @device_revision
      redirect_to :controller => 'atp', :action => 'work_orders'
    else
      flash[:warning] = 'Device Revision and Number Of Devices are Required.'
      @device_revisions = DeviceRevision.find(:all, :order => "revision desc", :include => {:device_model => :device_type})
      render :action => 'work_order_device_type_init'
    end
  end
end