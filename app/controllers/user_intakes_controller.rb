class UserIntakesController < ApplicationController
  before_filter :login_required

  # GET /user_intakes
  # GET /user_intakes.xml
  def index
    # TODO: needs re-factoring
    @groups = current_user.group_memberships # this will be a drop-down on user intake list
    _group = Group.find_by_name( @group_name = params[:group_name])
    #
    # show for the selected group, or, show all from current_user group_memberships
    @user_intakes = (_group.blank? ? @groups.collect(&:user_intakes).flatten.compact.uniq : _group.user_intakes)
    # filter: submission / save status
    @user_intake_status = params[:user_intake_status]
    @user_intakes = @user_intakes.select(&:locked?) if params[:user_intake_status] == "Submitted"
    # filter: user identity. id, name, first_name, last_name, anything matches the given values
    # can also acept comma separated values for multiple
    @user_identity = params[:user_identity]
    unless @user_identity.blank?
      phrases = params[:user_identity].split(',').collect(&:strip)
      # user intakes are selected here based on multiple criteria
      # * given csv phrase is split into csv_array
      # * user id, name, first_name, last_name from profile are checked against each element of csv_array
      # * name returns email or login, if profile is missing
      # * any given attribute of user can match at least one element of csv_array
      @user_intakes = @user_intakes.select do |user_intake|
        senior = user_intake.senior # fetch the senior. no worries even if it is blank. handled in next row
        # if user is blank? do not select this user_intake
        # if user identity matches, select, else fail
        # senior exists && any identity column of senior matches at least one phrase (even partially)
        senior && [senior.id.to_s, senior.name, senior.first_name, senior.last_name].compact.uniq.collect do |e|
          found = phrases.collect {|f| e.include?( f) } # collect booleans for any phrase matching this identity column
          found && found.include?( true) # at least one match is TRUE
        end.include?( true) # collection must have at least one TRUE
      end
    end
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
    @user_intake = UserIntake.new # ( :creator => current_user, :updater => current_user)
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
    @groups = current_user.group_memberships

    # QUESTION: Should we have some logic here to allow editing subject to state?
    #
    # * only allow editing user intakes that are submitted (not just saved)
    # * only super_admin can edit submitted ones
    # CHANGED: halouser or subscriber can edit its user intake
    if [@user_intake.senior, @user_intake.subscriber].include?( current_user) || @user_intake.group_admins.include?( current_user) || current_user.is_super_admin?
      respond_to do |format|
        format.html
        format.xml { render :xml => @user_intake }
      end

      # only super admin can edit a locked user intake
    elsif @user_intake.locked? && !current_user.is_super_admin?
      render :action => 'show'

      # at least redirect the user to some page and show a friendly message
    else
      flash[:notice] = "You are not authorized to edit this user intake form. Please contact the Administrator or MyHalo support."
      redirect_to :action => "index"
    end
  end

  # POST /user_intakes
  # POST /user_intakes.xml
  def create
    #
    # ramonrails: Fri Oct 14 10:40:54 IST 2010
    #   creator, updater introduced an error anytime when validation failed
    #   the values are not oerwritten here
    #   https://redmine.corp.halomonitor.com/issues/3497
    @user_intake = UserIntake.new(params[:user_intake]) # .merge( :creator => current_user, :updater => current_user))
    @user_intake.skip_validation = (params[:commit] == "Save") # just save without asking anything
    @groups = Group.for_user(current_user)

    # user intake form submission
    # Thu Oct 21 23:42:41 IST 2010
    #   user intake form now has a new hidden field 'user_intake_form_view'
    #   this will identify if the submission is coming from user intake form or any other interface
    #   we are updating user intake from many other places like update of 'shipping date' from overview
    if params.keys.include?( "user_intake_form_view")
      #
      # apply all attributes to associations
      @user_intake.apply_attributes_from_hash( params[:user_intake]) # apply user attributes
    end

    respond_to do |format|
      if @user_intake.save
        flash[:notice] = "User Intake was successfully #{params[:commit] == 'Save' ? 'saved' : 'created'}."
        format.html { redirect_to( :action => 'index') }
        format.xml  { render :xml => @user_intake, :status => :created, :location => @user_intake }
      else
        # this is required since we are maintaining the relational links to users, in user_intake object, not ORM
        # caregiver block will show blank, unless we do this
        @user_intake.build_associations # associated objects were removed just before the save. build them again
        format.html { render :action => "new" }
        format.xml  { render :xml => @user_intake.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /user_intakes/1
  # PUT /user_intakes/1.xml
  def update
    @user_intake = UserIntake.find(params[:id])
    @user_intake.skip_validation = (['Save', 'Print', 'Proceed'].include?(params[:commit])) # just save without asking anything
    @user_intake.locked = @user_intake.valid? unless @user_intake.skip_validation
    @groups = Group.for_user(current_user)

    respond_to do |format|
      # _attributes = params[:user_intake].reject {|k,v| v.is_a?(Hash) || k.include?( "attributes") }
      # _hashes = params[:user_intake].select {|k,v| v.is_a?(Hash) || k.include?( "attributes") }
      #
      # Thu Oct 21 23:58:40 IST 2010 : the fields were replaced by raw user intake columns
      # # ramonrails: Fri Oct 14 10:40:54 IST 2010
      # #   we have the current_user available at this moment, not inside the model
      # #   TODO: need a better fix. this is a rough patch
      # unless params[:user_intake].blank?
      #   params[:user_intake] = params[:user_intake].reject {|k,v| k == "creator"}
      #   params[:user_intake]["updater"] = current_user
      # end

      # user intake form submission
      # Thu Oct 21 23:42:41 IST 2010
      #   user intake form now has a new hidden field 'user_intake_form_view'
      #   this will identify if the submission is coming from user intake form or any other interface
      #   we are updating user intake from many other places like update of 'shipping date' from overview
      if params.keys.include?( "user_intake_form_view")
        #
        # Fri Oct 22 00:36:11 IST 2010
        #   * distributed logic in controller and model was causing issues like "Bill" button never visible
        #   * shifted the logic to model
        #   * lazy_action attribute holds the text of last button pushed
        #   * action will be perfoemed within model
        # # if approval was pending and this time "Approve" button is submitted
        # #   then mark the senior "Ready to Install"
        # if (@user_intake.senior.status == User::STATUS[:approval_pending]) && (params[:commit] == "Approve")
        #   @user_intake.senior.update_attribute_with_validation_skipping( :status, User::STATUS[:install_pending])
        #   @user_intake.senior.opt_in_call_center # start getting alerts, caregivers away, test_mode true
        # end
        params[:user_intake][:lazy_action] = params[:commit] # commit button text
        #
        # apply all attributes to associations
        @user_intake.apply_attributes_from_hash( params[:user_intake]) # apply user attributes
        #
        # Now save the user intake object. Should pass validation
        if @user_intake.update_attributes( params[:user_intake])
          #
          # proceed as usual
          flash[:notice] = 'User Intake was successfully updated.'
          format.html do
            #
            # QUESTION: Is this correct?
            #   We were showing successful order here but the busoness logic changed later
            #
            # if params[:redirect_hash].blank?
            redirect_to :action => 'index' # just show user_intakes
            # else
            #   redirect_to redirect_hash # this comes from online order form
            # end
          end
          format.xml  { head :ok }
        else
          format.html { render :action => "edit", :id => @user_intake.id }
          format.xml  { render :xml => @user_intake.errors, :status => :unprocessable_entity }
        end

        # single column/attribute updates from different interfaces like user intake overview
        #   * just a silent update of user intake attributes. no questions asked. no validations. no checking.
        #   * we need this for interfaces like 'shipping date update' from user intake overview
      else
        params[:user_intake].each {|k,v| @user_intake.send( "#{k}=".to_sym, v) }
        @user_intake.send( :update_without_callbacks) # just save it. no questions asked.
        flash[:notice] = "Successfully updated the user intake"
        format.html { redirect_to :action => 'index' }
      end # just one column updates
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

  def charge_subscription
    @user_intake = UserIntake.find( params[:id])
    @user_intake.order and @user_intake.order.charge_subscription # begin charge for subscription
  end

  def paper_copy_submission
    @user_intake = UserIntake.find(params[:id])
  end

  def safety_care_account_creation
    @user_intake = UserIntake.find(params[:id])
  end

  def shipped
    @user_intake = UserIntake.find(params[:id])
  end

  def add_notes
    unless (ids = (params[:selected] ? params[:selected].keys.collect(&:to_i) : [])).blank?
      user_intakes = UserIntake.find(ids)
      user_intakes.each {|e| e.add_triage_note( :description => params[:user_intake_note], :created_by => current_user.id) }
      flash[:notice] = "Triage note added for " + user_intakes.collect {|e| e.senior.blank? ? nil : e.senior.name }.compact.uniq.join(', ')
    end
    redirect_to :back # just go back to the last triage
  end
end
