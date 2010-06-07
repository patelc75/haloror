class UserAdminController < ApplicationController
  
  before_filter :authenticate_admin_moderator?, :except => ['new_admin', 'create']
  before_filter :authenticate_admin_sales?, :only => ['new_admin', 'create']
     
  def new_admin
    @groups = []
    if current_user.is_super_admin?
    	@groups = Group.find(:all)
    else
      gs = current_user.group_memberships
      gs.each do |g|
        @groups << g if(current_user.is_admin_of?(g))
      end
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
    @user.email = params[:user][:email]
    @group = params[:group]
    @profile = Profile.new(params[:profile])
    if !params[:role].blank? && params[:role] != 'Choose a Role'
      role_id = params[:role]
      role = Role.find_by_id(role_id)
      User.transaction do
        @user[:is_new_user] = true
        @user.created_by = current_user.id
        @user.save!        
        @profile.user_id = @user.id
        @profile.save!
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
    @roles = Role.distinct_names_only_all_except("caregiver", "super_admin") # make an array of [name, name]
    # @roles = []
    # rows = Role.connection.select_all("Select Distinct name from roles where name <> 'caregiver' AND name <> 'super_admin' order by name asc")
    # rows.collect do |row|
    #   @roles << row['name']
    # end
    @groups = current_user.groups_where_admin # where the user is member
    # @groups = []
    # rows = Group.connection.select_all("Select Distinct name from groups order by name asc")
    # rows.collect do |row|
    #   @groups << row['name']
    # end
    #
    # all users having any role in selected groups
    users = @groups.collect(&:users).flatten # collect users from the groups
    @users = User.all(:conditions => {:id => users.collect(&:id).compact.uniq}, :include => :profile, :order => 'profiles.first_name, profiles.last_name') # fetch uniq IDs and find again
    # @users = @groups.collect(&:users).flatten.uniq.sort! {|x,y| x.name <=> y.name }
    # @users = User.find(:all, :order => 'login asc')
  end
  
  def assign_super_role
    unless (user_id = params[:superadmin][:user_id]).blank?
      unless (user = User.find(user_id)).blank?
        user.has_role 'super_admin', Group.find_by_name('halo') # TODO: should we find_or_create_by ?
        @success = true
        @message = "Super Admin Role Assigned"
      else
        @success = false
        @message = "Choose a user"
      end
    end
    render :action => 'assign_role', :layout => false
  end
  
  def assign_role
    group_name = params[:role][:group_name]
    role_name = params[:role][:role_name]
    user_id = params[:role][:user_id] rescue nil # may error otherwise
    
    unless user_id.blank?
      unless group_name.blank?
        User.find(user_id).has_role role_name, Group.find_by_name(group_name)
      else
        User.find(user_id).has_role role_name
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
    user_id = params[:remove][:user_id]
    
    unless user_id.blank?
      unless group[:name].blank?
        g = Group.find_by_name(group[:name])
        r = Role.find(:first, :conditions => "name = '#{role[:name]}' AND authorizable_type = 'Group' AND authorizable_id = #{g.id}")
        if r
          roles_users = RolesUser.find(:all, :conditions => "user_id = #{user_id} AND role_id = #{r.id}")
          RolesUser.delete(roles_users)
          @success = true
          @message = "Role/Group Removed"
        else
    	  @success = false
    	  @message = "Role not found for selected user"
        end
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
  
  def groups
  	@groups = Group.find(:all)
  end
  
  def add_group
    group_name = params[:group_name]
    if(!group_name.blank?)
      if(Group.find_by_name(group_name).blank?)
      	if params[:sales_type] != ""
        @group = Group.create(:name => group_name,:description => params[:description],:sales_type => params[:sales_type])
          if @group.valid?
        	HALO_ROLES.each do |role|
        		Role.create(:name => role,:authorizable_type => 'Group',:authorizable_id => @group.id)
        	end
        	@success = true
        	@message = "Group(#{group_name}) Added"
          else
        	@success = false
        	@message = "Group Name is not valid. It should contains only lowercase characters  numeric values and underscore."
          end
        else
          @success = false
          @message = "Please select Sales Type for create group."
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
  
  def edit_group
  	@group = Group.find(params[:id])
  	if request.post?
		if @group.update_attributes!(:name => params[:group_name],:description => params[:description],:sales_type => params[:sales_type])
  			redirect_to :action => 'roles'
  		end
  	end
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