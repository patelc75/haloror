# 
#  Tue Jan 11 01:41:36 IST 2011, ramonrails
#   * https://redmine.corp.halomonitor.com/issues/3988
class InvoicesController < ApplicationController
  before_filter :authenticate_super_admin?
  
  def index
    @invoices = Invoice.ordered.paginate :page => params[:page], :per_page => 15
  end
  
  def new
    redirect_back_or_default('/') if params[:id].blank? # just get back if no ID given
    @invoice = Invoice.find_by_user_id( params[:id].to_i) # fetch any existing invoice
    if @invoice.blank?
      @invoice = Invoice.new( :user_id => params[:id].to_i) # fetch the user and assign to the new invoice
    else
      redirect_to :action => 'show', :id => @invoice # show the existing invoice instead ot creating
    end
  end
  
  def create
    @invoice = Invoice.new( params[:invoice])
    if @invoice.save
      flash[:notice] = "Successfully created the invoice for user: #{@invoice.user_name}..."
      redirect_to :action => 'show', :id => @invoice
    else
      render :action => 'new', :id => @invoice.user_id
    end
  end
  
  def edit
    @invoice = Invoice.find( params[:id].to_i)
  end
  
  def update
    if params.has_key?( "invoice_columns")
      @invoice = Invoice.find( params[:id].to_i)
      @invoice.attributes = params[:invoice]
      # @invoice.skip_validation = true # we do not want to validate for other attributes of Order
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
    @invoice = Invoice.find( params[:id].to_i)
  end
end
