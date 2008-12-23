require 'ruleby'
class CallCenterController < ApplicationController
  before_filter :authenticate_admin_operator?, :except => 'show'
  before_filter :authenticate_admin_operator_moderator?, :only => 'show'
  helper :utility
  include UtilityHelper
  include Ruleby
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
    unless @call_center_wizard = CallCenterWizard.find_by_event_id(params[:id])
      @call_center_wizard = CallCenterWizard.create(:event_id => @event.id, 
                                                    :user_id => @event.user_id, 
                                                    :operator_id => current_user.id,
                                                    :call_center_session_id => CallCenterSession.create(:event_id => @event.id).id)
      @call_center_wizard.save!
    end
    redirect_to :controller => 'call_center', 
                :action => 'script_wizard', 
                :event_id => @event.id,        
                :call_center_wizard_id => @call_center_wizard.id
  end
  def script_wizard
    @call_center_wizard = CallCenterWizard.find(params[:call_center_wizard_id])
    @event =  @call_center_wizard.event
    @user = @event.user
    @call_center_session =  @call_center_wizard.call_center_session
  end
  
  def script_wizard_start
    @call_center_wizard = CallCenterWizard.find(params[:call_center_wizard_id])
    @event =  @call_center_wizard.event
    @user = @event.user
    @call_center_session =  @call_center_wizard.call_center_session
    @call_center_step = @call_center_wizard.first_step()
    render :partial => 'script', :layout => false
  end
  def script_previous
    @call_center_wizard = CallCenterWizard.find(params[:call_center_wizard_id])
    @event =  @call_center_wizard.event
    @user = @event.user
    @call_center_session =  @call_center_wizard.call_center_session
    @call_center_step = CallCenterStep.find(params[:call_center_step_id])
    @call_center_step.answer = nil
    @call_center_step.notes = nil
    @call_center_step.save!
    render(:update) do |page|
      page['instruction_' + @call_center_step.id.to_s].replace_html ''
      page['answer_' + @call_center_step.id.to_s].replace_html ''
      page['notes_' + @call_center_step.id.to_s].replace_html ''
      page['breaker_' + @call_center_step.id.to_s].replace_html ''
      page << "accordion.step(#{@call_center_step.id});"
      page['call_center-wizard'].replace_html render(:partial => 'script', :layout => false)
    end
  end
  def script_next
    @call_center_wizard = CallCenterWizard.find(params[:call_center_wizard_id])
    @event =  @call_center_wizard.event
    @user = @event.user
    @call_center_session =  @call_center_wizard.call_center_session
    @call_center_step = @call_center_wizard.get_next_step(params[:call_center_step_id], params[:answer])
    if @call_center_step.nil?
      @call_center_step = CallCenterStep.new(:header => CallCenterWizard::THE_END,
                                              :script => "Please click <a style=\"color: white;\" href=\"/call_center/resolved/#{@event.id}\">here to Resolve</a> the event.",
                                              :instruction => CallCenterWizard::THE_END)
    end
    previous_step = CallCenterStep.find(params[:call_center_step_id])
    ans = previous_step.answer ? 'Yes' : 'No'
    if /Resolve/ =~ @call_center_step.script
      action = EventAction.new
      action.user_id = current_user.id
      action.event_id = @event.id
      action.description = 'resolved'
      action.save!
      send_admin_call_log_email()
       @call_center_step = CallCenterStep.new(:header => CallCenterWizard::THE_END,
                                                :script => "The event is now resolved. Click <a style=\"color: white;\" href=\"/call_center/index\">here</a> to go to the Call Center Overview.",
                                                :instruction => CallCenterWizard::THE_END)
    end
      render(:update) do |page|
        page['instruction_' + previous_step.id.to_s].replace_html previous_step.instruction
        page['answer_' + previous_step.id.to_s].replace_html ans
        page['breaker_' + previous_step.id.to_s].replace_html "<hr />"
        page << "accordion.step(#{@call_center_step.id});"
        page['call_center-wizard'].replace_html render(:partial => 'script', :layout => false)
      end
    
  end
  
  def script_note_save
    @call_center_step = CallCenterStep.find(params[:step_id])
    @call_center_step.notes = params[:script_note]
    @call_center_step.save!
    render(:update) do |page|
      #page['note_' + @call_center_step.id.to_s].replace_html @call_center_step.notes
      page['notes_text'].replace_html "#{@call_center_step.notes}<br /><a href=\"#\" onclick=\"$('notes_text').hide();$('notes').show();\">Edit Notes</a>"
      page['notes'].hide();
      page['notes_text'].show();
      page['notes_' + @call_center_step.id.to_s].replace_html "<div>" + @call_center_step.notes + "</div>"
      page['breaker_' + @call_center_step.id.to_s].replace_html "<hr />"
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
    if params[:group_id].blank?
      @group = @groups[0]
    else
      g = Group.find(params[:group_id])
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
  def send_admin_call_log_email()
    body = ""
    steps = @call_center_wizard.call_center_session.call_center_steps.sort do |a, b|
      a.updated_at <=> b.updated_at
    end
    steps.each do |step|
      if !step.answer.blank?
        body << "\n\n#{step.instruction}  \n#{step.answer}  \n#{step.notes}"
      end
    end
      accepted_time = UtilityHelper::seconds_format((@event.accepted?.created_at - @event.timestamp).seconds)
      resolved_time = UtilityHelper::seconds_format((@event.resolved?.created_at - @event.accepted?.created_at).seconds)
      total_time = UtilityHelper::seconds_format((@event.resolved?.created_at - @event.timestamp).seconds)
      body << "\n\n #{accepted_time} from event to accepted"
      body << "\n #{resolved_time} from accepted to resolved"
      body << "\n #{total_time} from event to resolved"
      recipients = User.super_admins()
      groups = @user.group_memberships
      admins = User.administrators()
      admins.each do |admin|
        if admin.is_admin_of_any?(groups)
          recipients << admin
        end
      end
      CriticalMailer.deliver_admin_call_log(@event, body, recipients)
  end
end
