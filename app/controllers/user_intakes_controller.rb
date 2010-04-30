class UserIntakesController < ApplicationController
  before_filter :login_required
  
  # GET /user_intakes
  # GET /user_intakes.xml
  def index
    @user_intakes = UserIntake.paginate :page => params[:page],:order => 'created_at desc',:per_page => 20

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
    @groups = Group.for_user(current_user)
  end

  # POST /user_intakes
  # POST /user_intakes.xml
  def create
    @user_intake = UserIntake.new(params[:user_intake])
    @groups = Group.for_user(current_user)

    respond_to do |format|
      if @user_intake.save
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
  
end
