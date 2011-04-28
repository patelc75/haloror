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
    
    if _model_type == 'user'
      profile = Profile.first(:conditions => { :user_id => _model_id })  
      @audits += Audit.all( :conditions => { :auditable_id => profile.id, :auditable_type => 'Profile' } ) 
      user_intake_object = @model_object.user_intakes[0]            
      @audits += Audit.all( :conditions => { :auditable_id => user_intake_object.id, :auditable_type => 'UserIntake' } ) if !user_intake_object.nil?    
    end

    @audits.sort! {|a,b| b.created_at <=> a.created_at } if @audits.length > 1
    @audits = @audits.paginate :per_page => 10, :page => params[:page] #ordering does not work for some reason: , :order => 'created_at desc'            
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
