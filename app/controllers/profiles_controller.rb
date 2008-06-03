class ProfilesController < ApplicationController
  # GET /profiles
  # GET /profiles.xml
  def index
    @profiles = Profile.find(:all)
 
    #   @profiled = Profile.find(params[:id])

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @profiles.to_xml }
    end
  end

  # GET /profiles/1
  # GET /profiles/1.xml
  def show
    @profile = Profile.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @profile.to_xml }
    end
  end

  # GET /profiles/new
  def new
    @profile = Profile.new
  end

  # GET /profiles/1;edit
  def edit
    @profile = Profile.find(params[:id])
  end

  # POST /profiles
  # POST /profiles.xml
  def create
    @profile = Profile.new(params[:profile])

    respond_to do |format|
      if @profile.save
        flash[:notice] = 'Profile was successfully created.'
        format.html { redirect_to profile_url(@profile) }
        format.xml  { head :created, :location => profile_url(@profile) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @profile.errors.to_xml }
      end
    end
  end

  # PUT /profiles/1
  # PUT /profiles/1.xml
  def update
    @profile = Profile.find_by_user_id(params[:user_id])

    respond_to do |format|
      if @profile.update_attributes(params[:profile])
        flash[:notice] = 'Profile was successfully updated.'
        format.html { redirect_to profile_url(@profile) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @profile.errors.to_xml }
      end
    end
  end

  # DELETE /profiles/1
  # DELETE /profiles/1.xml
  def destroy
    @profile = Profile.find(params[:id])
    @profile.destroy

    respond_to do |format|
      format.html { redirect_to profiles_url }
      format.xml  { head :ok }
    end
  end
  
  def edit_caregiver_profile
    @profile = Profile.find(params[:id], :include => :user)
    @user = @profile.user
    
    if(params[:roles_user_id])
      @roles_users_option = RolesUsersOption.find_by_roles_user_id(params[:roles_user_id])
    end
  end
  
  def update_caregiver_profile
    user = User.find(params[:user_id])
    user.email = params[:email]
    
    user.save

    if(params[:roles_user_id])
      @roles_users_option = RolesUsersOption.find_by_roles_user_id(params[:roles_user_id])
      @roles_users_option.relationship = params[:relationship]
      @roles_users_option.save
    end
        
    Profile.update(params[:id], params[:profile])
    
    if(params[:patient_id])
      refresh_caregivers(User.find(params[:patient_id]))
    end
  end
end