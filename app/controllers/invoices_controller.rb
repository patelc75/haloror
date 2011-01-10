# 
#  Tue Jan 11 01:41:36 IST 2011, ramonrails
#   * https://redmine.corp.halomonitor.com/issues/3988
class InvoicesController < ApplicationController
  before_filter :authenticate_super_admin?
  
  def index
    @invoices = Order.ordered.paginate :page => params[:page], :per_page => 15
  end
  
  def edit
    @invoice = Order.find( params[:id].to_i)
  end
  
  def update
    if params.has_key?( "invoice_columns")
      @invoice = Order.find( params[:id].to_i)
      @invoice.attributes = params[:order]
      @invoice.skip_validation = true # we do not want to validate for other attributes of Order
      if @invoice.save
        flash[:notice] = "Successfully updated..."
        redirect_to :action => 'show', :id => @invoice
      else
        render :controller => 'invoices', :action => 'edit', :id => @invoice.id
      end
    else
      redirect_to invoices_path
    end
  end
  
  def show
    @invoice = Order.find( params[:id].to_i)
  end
end
