class TriageThresholdsController < ApplicationController
  before_filter :login_required
  
  # GET /triage_thresholds
  # GET /triage_thresholds.xml
  def index
    @triage_thresholds = TriageThreshold.all(:conditions => {:group_id => params[:search]}).paginate :per_page => 10, :page => params[:page]
    @groups = current_user.groups_where_admin

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @triage_thresholds }
    end
  end

  # GET /triage_thresholds/1
  # GET /triage_thresholds/1.xml
  def show
    @triage_threshold = TriageThreshold.find(params[:id].to_i)
    @groups = current_user.groups_where_admin

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @triage_threshold }
    end
  end

  # GET /triage_thresholds/new
  # GET /triage_thresholds/new.xml
  def new
    @triage_threshold = TriageThreshold.new
    @groups = current_user.groups_where_admin

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @triage_threshold }
    end
  end

  # GET /triage_thresholds/1/edit
  def edit
    @triage_threshold = TriageThreshold.find(params[:id].to_i)
    @groups = current_user.groups_where_admin
  end

  # POST /triage_thresholds
  # POST /triage_thresholds.xml
  def create
    @triage_threshold = TriageThreshold.new(params[:triage_threshold])
    @groups = current_user.groups_where_admin

    respond_to do |format|
      if @triage_threshold.save
        flash[:notice] = 'TriageThreshold was successfully created.'
        format.html { redirect_to :controller => 'triage_thresholds', :action => 'show', :id => @triage_threshold }
        format.xml  { render :xml => @triage_threshold, :status => :created, :location => @triage_threshold }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @triage_threshold.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /triage_thresholds/1
  # PUT /triage_thresholds/1.xml
  def update
    @triage_threshold = TriageThreshold.find(params[:id].to_i)
    @groups = current_user.groups_where_admin

    respond_to do |format|
      if @triage_threshold.update_attributes(params[:triage_threshold])
        flash[:notice] = 'TriageThreshold was successfully updated.'
        format.html { redirect_to :controller => 'triage_thresholds', :action => 'show', :id => @triage_threshold }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @triage_threshold.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /triage_thresholds/1
  # DELETE /triage_thresholds/1.xml
  def destroy
    @triage_threshold = TriageThreshold.find(params[:id].to_i)
    @triage_threshold.destroy

    respond_to do |format|
      format.html { redirect_to :controller => 'triage_thresholds', :action => 'show', :id => @triage_threshold }
      format.xml  { head :ok }
    end
  end
end
