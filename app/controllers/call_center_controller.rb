class CallCenterController < ApplicationController
  before_filter :authenticate_admin_operator?, :except => 'show'
  before_filter :authenticate_admin_operator_moderator?, :only => 'show'
  include UtilityHelper
  
  def index
    events_per_page = 25
    conditions = ''
    if !current_user.is_super_admin?
      groups = current_user.group_memberships
      g_ids = []
      groups.each do |group|
        g_ids << group.id if(current_user.is_admin_of?(group) || current_user.is_operator_of?(group))
      end
      group_ids = g_ids.join(', ')
      RAILS_DEFAULT_LOGGER.warn(group_ids)
      conditions = "(event_type = 'Fall' or event_type = 'Panic') AND events.user_id IN (Select user_id from roles_users INNER JOIN roles ON roles_users.role_id = roles.id where roles.id IN (Select id from roles where authorizable_type = 'Group' AND authorizable_id IN (#{group_ids})))"
    else
      conditions = "event_type = 'Fall' or event_type = 'Panic'"
    end
    @events = Event.paginate :page => params[:page], :order => "(timestamp_server IS NOT NULL) DESC, timestamp_server DESC, timestamp DESC", :conditions => conditions, :per_page => events_per_page
  end 
  
  def accept
    @event = Event.find(params[:id])
    ea = @event.accepted?
    if !ea
      action = EventAction.new
      action.user_id = current_user.id
      action.event_id = params[:id]
      action.description = 'accepted'
      action.save!
      ea = action      
    end
    unless @call_center_steps_group = CallCenterStepsGroup.find_by_event_id(params[:id])
      @call_center_steps_group = create_call_center_steps_group()    
    end
    redirect_to :controller => 'call_center', 
                :action => 'script_wizard', 
                :event_id => @event.id,        
                :call_center_steps_group_id => @call_center_steps_group.id
  end
  def script_wizard
    @event = Event.find(params[:event_id])
    @call_center_steps_group = CallCenterStepsGroup.find(params[:call_center_steps_group_id])
    @call_center_steps = @call_center_steps_group.call_center_steps
    @call_center_steps.sort! do |a, b|
      a.created_at <=> b.created_at
    end
  end
  
  def script_wizard_next
    @call_center_steps_group = CallCenterStepsGroup.find(params[:call_center_steps_group_id])
    @event = @call_center_steps_group.event
    @call_center_steps = @call_center_steps_group.call_center_steps
    @call_center_steps.sort! do |a, b|
      a.created_at <=> b.created_at
    end
    @next_call_center_step = nil
    @previous_call_center_step = nil
    if(!params[:call_center_step_id].blank?)
      (0..@call_center_steps.size - 1).each do |i|
        if @call_center_steps[i].id.to_s == params[:call_center_step_id]
          @call_center_step = @call_center_steps[i]
          @previous_call_center_step = @call_center_steps[i - 1]  if i > 0
          @next_call_center_step = @call_center_steps[i + 1] if i < @call_center_steps.size
        end
      end
    else
      @call_center_step = @call_center_steps[0]
      if @call_center_steps.size > 1
        @next_call_center_step = @call_center_steps[1]
      end
    end
    render :partial => 'script', :layout => false
  end
  # def close_script_note
  #   @event = Event.find(params[:id])
  #   step = params[:step]
  #   render :text => ''
  # end
  # def init_script_note
  #   @event = Event.find(params[:id])
  #   step = params[:step]
  #   @call_center_step = CallCenterStep.find(:first, :conditions => "event_id = #{@event.id} and step_num = #{step}")
  #   unless @call_center_step
  #     @call_center_step = CallCenterStep.create(:event_id => @event.id, :step_num => step)
  #   end
  #   render :partial => 'script_note', :layout => false
  # end
  
  def script_note_save
    @event = Event.find(params[:event_id])
    @call_center_step = CallCenterStep.find(params[:step_id])
    @call_center_step.answer = params[:script_note]
    @call_center_step.save!
    render(:update) do |page|
      page['note_' + @call_center_step.id.to_s].replace_html @call_center_step.answer
    end
  end
  def resolved
    action = EventAction.new
    action.user_id = current_user.id
    action.event_id = params[:id]
    action.description = 'resolved'
    action.save!
    redirect_to :controller => 'call_center', :action => 'index'
  end
  
  def resolve
    # event = Event.find(params[:id])
    #     event.resolved_by = current_user.id
    #     event.resolved_at = Time.now
    #     event.save
    
    action = EventAction.new
    action.user_id = current_user.id
    action.event_id = params[:id]
    action.description = 'resolved'
    action.save
    
    render :partial => 'resolve', :locals => {:event => Event.find(params[:id])}
  end
  
  def show
    @user = current_user
    @groups = []
      if !@user.is_super_admin?
        @groups = Group.find(:all)
      else
        Group.find(:all).each do |g|
          @groups << g if(@user.is_operator_of?(g) || @user.is_moderator_of?(g) || @user.is_admin_of?(g))
        end
      end 
    if params[:id].blank?
      @group = @groups[0]
    else
      g = Group.find(params[:id])
      @group = g if @groups.include? g
    end
    @operators = []
    ops = User.operators
    ops.each do |op|
      @operators << op if(op.is_operator_of?(@group))
    end
    number_ext
  end
  
  def toggle_note
    if params[:new_note]
      @event_id = params[:event_id]
      @user_id = params[:user_id]
      @note = Note.new
      render :partial => 'notes', :layout => false
    else
      render :text => '', :layout => false
    end
  end
  
  def save_note
    note = nil
    if params[:id].blank?
      note = Note.new()
      note.event_id = params[:event_id]
      note.user_id = params[:user_id]
      note.created_at = Time.now
      note.created_by = current_user.id
      note.notes = params[:notes]
      note.save!
      if params[:new_note]
        redirect_to :controller => 'call_center', :action => 'all_user_notes', :id => params[:user_id]
      elsif params[:new_event_id]
        redirect_to :controller => 'call_center', :action => 'all_event_notes', :id => params[:event_id]
      else
        render :text => '', :layout => false
      end
    else 
      note = Note.find(params[:id])
      user_id = note.user_id
      note.created_by = current_user.id
      note.notes = params[:notes]
      note.save!
      @note = note
      render :partial => 'update_note', :layout => false
    end
    
  end
  def add_event_note
    event = Event.find(params[:event_id])
    @note = Note.new()
    @note.user_id = params[:user_id]
    @note.event = event
    render :partial => 'add_event_note', :layout => false
  end
  def add_note
    @note = Note.new(:user_id => params[:user_id])
    render :partial => 'add_note', :layout => false
  end
  def edit_note
    @note = Note.find(params[:id])
    render :partial => 'note', :layout => false
  end
  def delete_note
    note = Note.find(params[:id])
    user_id = note.user_id
    Note.delete(note)
    redirect_to :action => 'all_user_notes', :id => user_id
  end
  def all_user_notes
    @title = "User Notes"
    user_id = params[:id]
    @user_id = user_id
    @notes = Note.find(:all, :conditions => "user_id = #{user_id}", :order => "created_at desc")
    render :template => 'call_center/all_notes'
  end
  def all_event_notes
    @title = "Event Notes"
    @event_id = params[:id]
    event = Event.find(@event_id)
    @user_id = event.user_id
    @notes = Note.find(:all, :conditions => "event_id = #{@event_id}", :order => "created_at desc")
    render :template => 'call_center/all_notes'
  end
  
  private 
  
  def create_call_center_steps_group()
    group = CallCenterStepsGroup.create(:event_id => @event.id)
    user = @event.user
    caregivers = user.active_caregivers
		caregivers.each do |caregiver|
		  step = CallCenterStep.new(:call_center_steps_group_id => group.id)
		  step.instruction = "Call Caregiver ##{caregiver.position} #{caregiver.contact_info}"
		  step.script = "Call Caregiver ##{caregiver.position} #{caregiver.contact_info_table}"
		  step.save!
	  end
	  step = CallCenterStep.new(:call_center_steps_group_id => group.id)
	  step.instruction = "Call User #{user.contact_info}"
	  step.script = "Call User #{user.contact_info_table}"
	  step.save!
	  step = CallCenterStep.new(:call_center_steps_group_id => group.id)
	  step.instruction = "Please click <a href=\"/call_center/resolved/#{@event.id}\">here to Resolve</a> the event."
	  step.script = "Please click <a href=\"/call_center/resolved/#{@event.id}\">here to Resolve</a> the event."
	  step.save!
	  group.reload
	  return group
  end
end
