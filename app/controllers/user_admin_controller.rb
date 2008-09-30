class UserAdminController < ApplicationController
  
  before_filter :authenticate_admin_moderator?, :except => ['new_admin', 'create_admin']
  before_filter :authenticate_admin?, :only => ['new_admin', 'create_admin']
     
  def new_admin
    @groups = []
    gs = current_user.group_memberships
    gs.each do |g|
      @groups << g if(current_user.is_admin_of?(g) || current_user.is_super_admin?)
    end
    @group = nil
    if params[:group].blank?
      if @groups.size == 1
        @group = @groups[0].name
      end
    else
      @group = params[:group]
    end
    if @group
      @user = User.new
      g = Group.find_by_name(@group)
      @roles = Role.find_all_by_authorizable_type_and_authorizable_id('Group', g.id, :conditions => "name <> 'halouser'", :order => 'name')
    end
  end

  def create_admin
    @user = User.new(params[:user])
    @group = params[:group]
    role_id = params[:role]
    role = Role.find(role_id)
    User.transaction do
        @user.save!
        
      # create profile
        Profile.create(:user_id => @user.id)
      # assign role
        @user.roles << role
    end
  end
  
  def roles
    @roles = []
    rows = Role.connection.select_all("Select Distinct name from roles where name <> 'caregiver' AND name <> 'super_admin' order by name asc")
    rows.collect do |row|
      @roles << row['name']
    end
    @groups = []
    rows = Group.connection.select_all("Select Distinct name from groups order by name asc")
    rows.collect do |row|
      @groups << row['name']
    end
    @users = User.find(:all, :order => 'login asc')
  end
  
  def assign_super_role
    user_id = params[:user_id]
    unless user_id.empty?
      User.find(user_id).has_role 'super_admin', Group.find_by_name('halo')
      @success = true
      @message = "Super Admin Role Assigned"
    else
      @success = false
      @message = "Choose a user"
    end
    render :action => 'assign_role', :layout => false
  end
  
  def assign_role
    group = params[:group]
    role = params[:role]
    user_id = params[:user_id]
    
    unless user_id.empty?
      unless group[:name].empty?
        User.find(user_id).has_role role[:name], Group.find_by_name(group[:name])
      else
        User.find(user_id).has_role role[:name]
      end
      
      @success = true
      @message = "Role/Group Assigned"
    else
      @success = false
      @message = "Choose a user"
    end   
    
    render :layout => false 
  end
  
  def assign_caregiver_role
    caregiver_id = params[:caregiver_id]
    user_id = params[:user_id]
    unless caregiver_id.empty?
      unless user_id.empty?
        User.find(caregiver_id).has_role 'caregiver', User.find(user_id)
        @success = true
        @message = "Caregiver Role Assigned"
      else
        @success = false
        @message = "Choose a caregiver"
      end
    else
      @success = false
      @message = "Choose a user"
    end
    render :action => 'assign_role', :layout => false
  end
end