class TriageAuditLogsController < ApplicationController
  before_filter :login_required
  
  def index
    # pick user_id, id or current_user.id
    @triage_audit_logs = TriageAuditLog.find_all_by_user_id( params[:id], :order => "updated_at DESC").paginate :page => params[:page], :per_page => 10
    
    respond_to do |format|
      format.html
      format.xml { render :xml => @triage_audit_logs, :status => :ok }
    end
  end
  
  def new
    @triage_audit_log = TriageAuditLog.new(:user_id => params[:user_id], :is_dismissed => params[:is_dismissed])
  end
  
  def create
    @triage_audit_log = TriageAuditLog.new( params[:triage_audit_log].merge( :created_by => current_user.id))
    user = User.find(params[:triage_audit_log][:user_id])

    respond_to do |format|
      if @triage_audit_log.save
        flash[:notice] = "#{user ? user.name : 'Triage row' } was #{@triage_audit_log.is_dismissed ? '' : 'un-'}dismissed."
        format.html { redirect_to :controller => 'users', :action => 'triage' }
      else
        format.html { render :action => "new" }
      end
    end
  end
  
  # GET /triage_audit_logs/1
  # GET /triage_audit_logs/1.xml
  def show
    redirect_to :action => "edit", :id => params[:id]
    # @triage_audit_log = TriageAuditLog.find(params[:id])
    # 
    # respond_to do |format|
    #   format.html # show.html.erb
    #   format.xml  { render :xml => @triage_audit_log }
    # end
  end
  
  # GET /triage_audit_logs/1/edit
  def edit
    @triage_audit_log = TriageAuditLog.find(params[:id])
  end
  
  # PUT /triage_audit_logs/1
  # PUT /triage_audit_logs/1.xml
  def update
    @triage_audit_log = TriageAuditLog.find(params[:id])

    respond_to do |format|
      if @triage_audit_log.update_attributes(params[:triage_audit_log].merge( :updated_by => current_user.id))
        flash[:notice] = 'Triage Audit Log was successfully updated.'
        format.html { redirect_to :controller => "triage_audit_logs", :id => @triage_audit_log.user_id }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit", :id => @triage_audit_log.id }
        format.xml  { render :xml => @triage_audit_log.errors, :status => :unprocessable_entity }
      end
    end
  end
  
end