class TriageAuditLogsController < ApplicationController
  before_filter :login_required
  
  def new
    @triage_audit_log = TriageAuditLog.new(:user_id => params[:user_id], :is_dismissed => params[:is_dismissed])
    
    respond_to do |format|
      format.html
    end
  end
  
  def create
    @triage_audit_log = TriageAuditLog.new(params[:triage_audit_log])
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
end