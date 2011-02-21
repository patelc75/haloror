class UserAdminController < ApplicationController
  
  before_filter :authenticate_admin_moderator?, :except => ['new_admin', 'create']
  before_filter :authenticate_admin_sales?, :only => ['new_admin', 'create']
     
  def new_admin
    # * pick all groups for super admins
    # * pick only selective groups for non-super-admin, where user is admin
    @groups = current_user.group_memberships # ( current_user.is_super_admin? ? Group.ordered : current_user.is_admin_of_what )
    # @groups = []
    # if current_user.is_super_admin?
    #   @groups = Group.find(:all)
    # else
    #   # old logic
    #   #
    #   # gs = current_user.group_memberships
    #   # gs.each do |g|
    #   #   @groups << g if(current_user.is_admin_of?(g))
    #   # end
    #   #
    #   # new logic
    #   @groups = current_user.is_admin_of_what
    # end

    @group_name = (params[:group_name] || @groups.first.name)
    # @group = nil
    # if params[:group].blank? || params[:group] == 'Choose a Group'
    #   if @groups.size == 1
    #     @group = @groups[0].name
    #   end
    # else
    #   @group = params[:group]
    # end

    # if @group
    @user = User.new # will also instantiate a profile object
    #
    # TODO: DRY: use "profile_attributes" in the partial instead of separate profile object
    @profile = @user.profile # Profile.new. Why do we need it at all?
    # g = Group.find_by_name(@group)
    # @group_roles = Role.find_all_by_authorizable_type_and_authorizable_id('Group', g.id, :conditions => "name <> 'halouser'", :order => 'name')
    @roles = ( Role.all_distinct_names_except("caregiver", "installer", "moderator", "sales", "subscriber") || [Role.new] )
    # end
  end

  def create
    @user = User.new(params[:user])
    # @user.email = params[:user][:email] # already assigned with :user
    @group_name = params[:group_name]
    # @profile = Profile.new(params[:profile]) # build_profile used now
    @roles = Role.distinct_by_name.ordered
    #
    # We need group specific code before the "if" condition
    @groups = current_user.group_memberships
    _group = Group.find_by_name(@group_name) # || @groups.first) # Group.first causing issues in manual test. cuke runs green
    #
    # if role was not properly selected for some reason
    if params[:role].blank? # && params[:role] != 'Choose a Role'
      # DEPRECATED: user.group_memberships take care of all this logic now
      # @groups = []
      # gs = current_user.group_memberships
      # gs.each do |g|
      #   @groups << g if(current_user.is_sales_of?(g) || current_user.is_admin_of?(g) || current_user.is_super_admin?)
      # end
      #
      # @roles = Role.find_all_by_authorizable_type_and_authorizable_id('Group', _group.id, :conditions => "name <> 'halouser'", :order => 'name')
      flash[:warning] = 'Role Required.'
      render :action => 'new_admin'

    else
      #
      # DEPRECATED: we do not need to find the ID for role
      #   This user should simply have the role for the group
      # role_id = params[:role]
      # role = Role.find_by_id(role_id)
      User.transaction do
        # 
        #  Wed Feb  9 22:28:56 IST 2011, ramonrails
        #   * FIXME: before_save not trigerring for some reason. check later
        @user.autofill_login
        # @user[:is_new_user] = true # DEPRECATED: this logic is not used anymore
        @user.created_by = current_user.id # TODO: DRY: include this in partial. no need to assign here
        #
        # assign the profile association
        @user.build_profile( params[:profile])
        #
        # TODO: these are quick fix. need better implementation
        # @user.autofill_login # just place some random login for now. user will activate later
        @user.skip_validation = true # do not validate profile. just capture the form
        # 
        #  Tue Dec 21 00:56:54 IST 2010, ramonrails
        #   * Need role at user level
        @user.lazy_roles[ :admin] = _group
        #
        if @user.save # "!" is not recommended here
          # TODO: render or redirect is not explicit when "save" fails
          #
          #   * already above
          # # TODO: DRY: profile can auto assign if we use profile_attributes in partial
          # @profile.user_id = @user.id
          # @profile.save # "!" is not recommended here
          #
          #  Tue Dec 21 00:57:14 IST 2010, ramonrails
          #   * shifted to user.lazy_roles above "save"
          # # DEPRECATED: why assign a role like this. use authorization plugin methods instead
          # #   # @user.roles << role
          # #   user.is_admin_of( group) uses authorization methods
          # #   CHANGED: not working correctly sometimes. better to use simpler syntax
          # @user.has_role params[:role], _group # more technical syntax but works better
          #
          # Tue Oct 26 04:32:30 IST 2010
          #   email is triggered from user model
          # # @user.send( "is_#{params[:role].gsub(' ','_').downcase}_of".to_sym, _group)
          # @user.dispatch_emails # explicitly send emails

        else # save failed?
          render :action => 'new_admin'
        end
      end
    end
  
  # TODO: DRY: this will not be required once we use appropriate attributes in partials
  #   This can be a simple respond_to action block without exceptions
  #   profile_top partial is used at many places. Can only DRY once code is fully covered
  rescue Exception => e
    RAILS_DEFAULT_LOGGER.warn("ERROR signing up, #{e}")
    #
    # g = Group.find_by_name(@group_name)
    # @roles = Role.find_all_by_authorizable_type_and_authorizable_id('Group', g.id, :conditions => "name <> 'halouser'", :order => 'name')
    render :action => 'new_admin'
  end
  
  def roles
    @roles = Role.all_distinct_names_except("caregiver", "super_admin") # make an array of [name, name]
    # @roles = []
    # rows = Role.connection.select_all("Select Distinct name from roles where name <> 'caregiver' AND name <> 'super_admin' order by name asc")
    # rows.collect do |row|
    #   @roles << row['name']
    # end
    @groups = current_user.groups_where_admin # where the user is member, super user gets all groups
    # @groups = []
    # rows = Group.connection.select_all("Select Distinct name from groups order by name asc")
    # rows.collect do |row|
    #   @groups << row['name']
    # end
    #
    # all users having any role in selected groups
    user_ids = @groups.collect(&:users).flatten.compact.collect(&:id).uniq # collect users from the groups
    @users = User.all(:conditions => {:id => user_ids}, :include => :profile, :order => 'profiles.first_name, profiles.last_name') # fetch uniq IDs and find again
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
    
    # 
    #  Sat Jan 29 00:51:18 IST 2011, ramonrails
    #   * https://redmine.corp.halomonitor.com/issues/4119
    unless user_id.blank?
      _user = User.find(user_id) # fetch user for use later in this script
      unless _user.blank? || group_name.blank? # check if user was found
        _group = Group.find_by_name(group_name) # fetch group for buffer
        _user.has_role role_name, _group
        if (role_name == 'halouser') && !_group.blank? # if halouser role assigned, change user_intakes as well
          #   * Symptom: user intake disappeared when group changed for halouser
          #   * WARNING: Multiple user intakes is possible? Very risky business logic here
          # 
          #  Tue Feb  8 02:40:03 IST 2011, ramonrails
          #   * https://redmine.corp.halomonitor.com/issues/4119#note-17
          #   * update associated user intake with no group assigned yet
          #  Thu Feb 10 01:50:51 IST 2011, ramonrails
          #   * https://redmine.corp.halomonitor.com/issues/4119#note-25
          #   * config > roles can change status of senior.is_halouser_of?( self.group)
          #   * changing the role of "sole" halouser to a different group will also change the group of user intake
          #   * adding additional halousers to the group will not change the group of user intake
          #   * in other words, a user intake will not auto-change the group as long as a user from user_intake.users has a halouser role for that group
          # 
          #  Thu Feb 10 02:31:26 IST 2011, ramonrails
          #   * https://redmine.corp.halomonitor.com/issues/4119#note-29
          _user.user_intakes.select {|e| e.halouser.blank? }.each do |ui| # pick user intakes orphaned of halouser
            ui.group = _group # assign halouser's group
            ui.send( :update_without_callbacks)
            # 
            #  Mon Feb 21 22:39:14 IST 2011, ramonrails
            #   * https://redmine.corp.halomonitor.com/issues/4226#note-5
            #   * update the order to show the same group as user intake
            #   * update only when an order is associated. user intakes can also be created without an order
            if (_order = ui.order)
              _order.group = ui.group
              _order.send( :update_without_callbacks)
            end
          end
        end
      else
        _user.has_role role_name
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
    group_name = params[:new_group_name]
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
    flash[:notice] = @message
    redirect_to :controller => "user_admin", :action => "roles"
    # render :action => 'assign_role', :layout => false
  end
  
  def edit_group
  	@group = Group.find(params[:id])
  	if request.post?
		if @group.update_attributes!(:name => params[:group_name],:email => params[:email],:description => params[:description],:sales_type => params[:sales_type])
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