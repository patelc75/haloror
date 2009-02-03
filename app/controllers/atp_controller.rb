class AtpController < ApplicationController
  before_filter :authenticate_super_admin?
  def index
    
  end
  
  def report
    @atp_test_results = AtpTestResult.find(:all)
  end
  def atp_test_result_view
    @atp_test_result = AtpTestResult.find(params[:id], :include => :atp_item_results)
  end
  
  def device_types_init
    @device_types = DeviceType.find(:all, :order => 'id asc')
  end
  
  def device_type_new
    @device_type = DeviceType.new
  end
  
  def device_type_edit
    @device_type = DeviceType.find(params[:id])
  end
  
  def device_type_save
    @device_type = DeviceType.new(params[:device_type])
    @device_type.save!
    redirect_to :action => 'device_types_init'
  end
  
  def device_type_update
    @device_type = DeviceType.find(params[:device_type][:id])
    @device_type.update_attributes(params[:device_type])
    @device_type.save!
    redirect_to :action => 'device_types_init'
  end
  
  def device_models_init
    @device_models = DeviceModel.find(:all, :order => "id asc", :include => :device_type)
  end
  
  def device_model_new
    @device_model = DeviceModel.new
    @device_types = DeviceType.find(:all, :order => "id asc")
  end
  
  def device_model_edit
    @device_model = DeviceModel.find(params[:id])
    @device_types = DeviceType.find(:all, :order => "id asc")
  end
  
  def device_model_save
    @device_model = DeviceModel.new(params[:device_model])
    @device_model.save!
    redirect_to :action => 'device_models_init'
  end
  
  def device_model_update
    @device_model = DeviceModel.find(params[:device_model][:id])
    @device_model.update_attributes(params[:device_model])
    @device_model.save!
    redirect_to :action => 'device_models_init'
  end
  
  def device_revisions_init
    @device_revisions = DeviceRevision.find(:all, :order => "id asc", :include => {:device_model => :device_type})
  end
  
  def device_revision_new
    @device_revision = DeviceRevision.new
    @device_models = DeviceModel.find(:all, :order => "id asc", :include => :device_type)
  end
  
  def device_revision_edit
    @device_revision = DeviceRevision.find(params[:id])
    @device_models = DeviceModel.find(:all, :order => "id asc", :include => :device_type)
  end
  
  def device_revision_save
    @device_revision = DeviceRevision.new(params[:device_revision])
    @device_revision.save!
    redirect_to :action => 'device_revisions_init'
  end
  
  def device_revision_update
    @device_revision = DeviceRevision.find(params[:device_revision][:id])
    @device_revision.update_attributes(params[:device_revision])
    @device_revision.save!
    redirect_to :action => 'device_revisions_init'
  end
  
  def atp_items_init
    @atp_items = AtpItem.find(:all, :order => "id asc")
  end
  
  def atp_item_new
    @atp_item = AtpItem.new
    @device_revisions = DeviceRevision.find(:all, :include => {:device_model => :device_type})
  end
  
  def atp_item_edit
    @atp_item = AtpItem.find(params[:id])
    @device_revisions = DeviceRevision.find(:all, :include => {:device_model => :device_type})
  end
  
  def atp_item_save
    @atp_item = AtpItem.new(params[:atp_item])
    @atp_item.save!
    redirect_to :action => 'atp_items_init'
  end
  
  def atp_item_update
    @atp_item = AtpItem.find(params[:atp_item][:id])
    @atp_item.update_attributes(params[:atp_item])
    @atp_item.save!
    redirect_to :action => 'atp_items_init'
  end
  
  def atp_item_device_revision_init
    @atp_item = AtpItem.find(params[:id])
    @device_revisions = DeviceRevision.find(:all, :order => "revision desc", :include => {:device_model => :device_type})    
  end
  
  def atp_item_device_revision_save
    @atp_item = AtpItem.find(params[:atp_item][:id])
    if !params[:device_revision][:id].blank?
      @device_revision = DeviceRevision.find(params[:device_revision][:id])
      @atp_item.device_revisions << @device_revision
      redirect_to :action => 'atp_items_init'
    else
      flash[:warning] = 'Device Revision and Number Of Devices are Required.'
      @device_revisions = DeviceRevision.find(:all, :order => "revision desc", :include => {:device_model => :device_type})
      render :action => 'atp_item_device_revision_init'
    end
  end

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
      @work_order.save!
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
      render :action => 'work_order_device_revision_init'
    end
  end
end