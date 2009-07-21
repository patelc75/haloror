class WorkOrdersController < ApplicationController
  def index
    work_orders = find_work_orders
    if work_orders
      #exlude the device_revision tree refs #1790
      #xml = work_orders.to_xml(:skip_types => true, :dasherize => false, :include => 
      #      {:device_revisions => {:include => {:atp_items => {}, :device_model => {:include => {:device_type => {}}}}}})
      xml = work_orders.to_xml(:skip_types => true, :dasherize => false)

      respond_to do |format|
        format.xml { render :xml => xml }
      end
    else
      respond_to do |format|
        format.xml { head :ok }
      end
    end
  end
  
  private
  
  def find_work_orders
    return WorkOrder.find(:all, :include => [{:device_revisions => :atp_items}])
  end
end