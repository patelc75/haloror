class AuditsController < ApplicationController
  # GET /audits
  # GET /audits.xml
  def index
    @user = User.find( params[:user_id])
    @audits = Audit.all( :conditions => { :auditable_id => params[:user_id], :auditable_type => "User" } )
    @audits = @audits.paginate :per_page => 10, :page => params[:page]

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @audits }
    end
  end

  # GET /audits/1
  # GET /audits/1.xml
  def show
    @audit = Audit.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @audit }
    end
  end
end
