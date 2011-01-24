class AuditsController < ApplicationController
  # GET /audits
  # GET /audits.xml
  def index
    _model_type = if params[:user_id]
      'user'
    elsif params[:invoice_id]
      'invoice'
    else
      nil
    end
    # @partial = ( _model_type.blank? ? 'blank_audit' : "#{_model_type}_audit")
    _model_id = params["#{_model_type}_id"] # we just collected this parameter name above
    @model_object = _model_type.classify.constantize.find( _model_id)
    @audits = Audit.all( :conditions => { :auditable_id => _model_id, :auditable_type => _model_type.split('_').first.classify } )
    @audits = @audits.paginate :per_page => 10, :page => params[:page]

    # respond_to do |format|
    #   format.html # index.html.erb
    #   format.xml  { render :xml => @audits }
    # end
  end

  # GET /audits/1
  # GET /audits/1.xml
  def show
    @audit = Audit.find(params[:id])

    # respond_to do |format|
    #   format.html # show.html.erb
    #   format.xml  { render :xml => @audit }
    # end
  end
end
