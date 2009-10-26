class UserAdminController < ApplicationController
  
  before_filter :authenticate_admin_moderator?, :except => ['new_admin', 'create']
  before_filter :authenticate_admin_sales?, :only => ['new_admin', 'create']
     
  def new_admin
    @groups = []
    gs = current_user.group_memberships
    gs.each do |g|
      @groups << g if(current_user.is_admin_of?(g) || current_user.is_super_admin?) || current_user.is_sales?
    end
    @group = nil
    if params[:group].blank? || params[:group] == 'Choose a Group'
      if @groups.size == 1
        @group = @groups[0].name
      end
    else
      @group = params[:group]
    end
    if @group
      @user = User.new
      @profile = Profile.new
      g = Group.find_by_name(@group)
      @group_roles = Role.find_all_by_authorizable_type_and_authorizable_id('Group', g.id, :conditions => "name <> 'halouser'", :order => 'name')
    end
  end

  def create
    @user = User.new(params[:user])
    @user.email = params[:email]
    @group = params[:group]
    @profile = Profile.new(params[:profile])
    if !params[:role].blank? && params[:role] != 'Choose a Role'
      role_name = params[:role]
      role = Role.find_by_name(role_name)
      User.transaction do
        @user[:is_new_user] = true
        @user.save!        
      # create profile
        @profile.user_id = @user.id
        @profile.save!
      # assign role
        @user.roles << role
      end
    else
      @groups = []
      gs = current_user.group_memberships
      gs.each do |g|
        @groups << g if(current_user.is_sales_of?(g) || current_user.is_admin_of?(g) || current_user.is_super_admin?)
      end
      g = Group.find_by_name(@group)
      @group_roles = Role.find_all_by_authorizable_type_and_authorizable_id('Group', g.id, :conditions => "name <> 'halouser'", :order => 'name')
      flash[:warning] = 'Role Required.'
      render :action => 'new_admin'
    end
  rescue Exception => e
    RAILS_DEFAULT_LOGGER.warn("ERROR signing up, #{e}")
    g = Group.find_by_name(@group)
    @group_roles = Role.find_all_by_authorizable_type_and_authorizable_id('Group', g.id, :conditions => "name <> 'halouser'", :order => 'name')
    render :action => 'new_admin'
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
  
  def remove_role
    group = params[:group]
    role = params[:role]
    user_id = params[:user_id]
    
    unless user_id.empty?
      unless group[:name].empty?
        g = Group.find_by_name(group[:name])
        r = Role.find(:first, :conditions => "name = '#{role[:name]}' AND authorizable_type = 'Group' AND authorizable_id = #{g.id}")
        roles_users = RolesUser.find(:all, :conditions => "user_id = #{user_id} AND role_id = #{r.id}")
        RolesUser.delete(roles_users)
        @success = true
        @message = "Role/Group Removed"
      else
        user = User.find(user_id)
        roles = user.roles.find(:all, :conditions => "name = '#{role[:name]}'")
        if roles
          roles.each do |r|
            roles_users = RolesUser.find(:all, :conditions => "user_id = #{user_id} AND role_id = #{r.id}")
            RolesUser.delete(roles_users)
          end
        end        
        @success = true
        @message = "Role Removed"
      end
      
      
    else
      @success = false
      @message = "Choose a user"
    end   
    
    render :action => 'assign_role', :layout => false 
  end
  
  def add_group
    group_name = params[:group_name]
    if(!group_name.blank?)
      if(Group.find_by_name(group_name).blank?)
        @group = Group.create(:name => group_name)
        if @group.valid?
        	@success = true
        	@message = "Group(#{group_name}) Added"
        else
        	@success = false
        	@message = "Group Name is not valid. It should contains only lowercase characters or numeric values."
        end
      else
        @success = false
        @message = "Group(#{group_name}) Already exists"
      end
    else
       @success = false
       @message = "Choose a user"
    end
    render :action => 'assign_role', :layout => false
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