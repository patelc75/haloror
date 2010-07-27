class UserIntakesController < ApplicationController
  before_filter :login_required
  
  # GET /user_intakes
  # GET /user_intakes.xml
  def index
    @groups = Group.for_user(current_user)
    @group_name = params[:group_name]
    group = Group.find_by_name(@group_name) unless @group_name.blank?
    @user_intakes = (group.blank? ? UserIntake.recent_on_top.all : UserIntake.recent_on_top.find_all_by_group_id(group.id))
    @user_intake_status = params[:user_intake_status]
    @user_intakes = @user_intakes.select(&:locked?) if params[:user_intake_status] == "Submitted"
    @user_intakes = @user_intakes.paginate :page => params[:page],:order => 'created_at desc',:per_page => 10

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @user_intakes }
    end
  end
  
  # GET /user_intakes/1
  # GET /user_intakes/1.xml
  def show
    @user_intake = UserIntake.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user_intake }
    end
  end

  # GET /user_intakes/new
  # GET /user_intakes/new.xml
  def new
    @user_intake = UserIntake.new
    @groups = Group.for_user(current_user)

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user_intake }
    end
  end

  # GET /user_intakes/1/edit
  def edit
    @user_intake = UserIntake.find(params[:id])
    @user_intake.build_associations
    @groups = Group.for_user(current_user)
    if @user_intake.locked?
      render :action => 'show'
    end
  end

  # POST /user_intakes
  # POST /user_intakes.xml
  def create
    @user_intake = UserIntake.new(params[:user_intake])
    @user_intake.skip_validation = (params[:commit] == "Save") # just save without asking anything
    @groups = Group.for_user(current_user)

    respond_to do |format|
      if @user_intake.save
        [@user_intake.senior, @user_intake.subscriber].uniq.each(&:dispatch_emails) unless @user_intake.skip_validation # send emails
        flash[:notice] = 'User Intake was successfully created.'
        format.html { redirect_to(:action => 'show', :id => @user_intake.id) }
        format.xml  { render :xml => @user_intake, :status => :created, :location => @user_intake }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user_intake.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /user_intakes/1
  # PUT /user_intakes/1.xml
  def update
    @user_intake = UserIntake.find(params[:id])
    @user_intake.skip_validation = ['Save', 'Print', 'I Agree'].include?(params[:commit]) # just save without asking anything
    @user_intake.locked = @user_intake.valid? unless @user_intake.skip_validation
    @groups = Group.for_user(current_user)

    respond_to do |format|
      if @user_intake.update_attributes(params[:user_intake])
        flash[:notice] = 'User Intake was successfully updated.'
        format.html { redirect_to(:action => 'show', :id => @user_intake.id) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit", :id => @user_intake.id }
        format.xml  { render :xml => @user_intake.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /user_intakes/1
  # DELETE /user_intakes/1.xml
  def destroy
    @user_intake = UserIntake.find(params[:id])
    @user_intake.destroy

    respond_to do |format|
      format.html { redirect_to(:action => 'index') }
      format.xml  { head :ok }
    end
  end

  def paper_copy_submission
    @user_intake = UserIntake.find(params[:id])
  end
  
end
