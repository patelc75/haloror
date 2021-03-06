# require 'ruleby'
class CallCenterController < ApplicationController
  before_filter :authenticate_admin_operator?, :except => 'show'
  before_filter :authenticate_admin_operator_moderator?, :only => 'show'
  helper :utility
  include UtilityHelper
  # include Ruleby
  def index
    events_per_page = 25
    conditions = ''
    
    if !current_user.is_super_admin?
      @groups = current_user.group_memberships
      g_ids = []
      g_ids << 0
      @groups.each do |group|
        g_ids << group.id if(current_user.is_admin_of?(group) || current_user.is_operator_of?(group))
      end
      group_ids = g_ids.join(', ')
      RAILS_DEFAULT_LOGGER.warn(group_ids)
      conditions = "events.user_id IN (Select user_id from roles_users INNER JOIN roles ON roles_users.role_id = roles.id where roles.id IN (Select id from roles where authorizable_type = 'Group' AND authorizable_id IN (#{group_ids})))"
    else
      @groups = Group.find(:all)  
    end
    if params[:group_name] and params[:group_name] != "Choose a Group"
        group = Group.find_by_name(params[:group_name])
      conditions = "events.user_id IN (Select user_id from roles_users INNER JOIN roles ON roles_users.role_id = roles.id where roles.id IN (Select id from roles where authorizable_type = 'Group' AND authorizable_id = #{group.id}))"
    end
    
    if params[:commit]
      conditions += conditions == '' ? set_checkbox_conditions : ' and ' + set_checkbox_conditions
    else
      conditions = "event_type = 'Fall' or event_type = 'Panic' or event_type = 'GwAlarmButton'"
    end
    @events = Event.find(:all, :conditions => conditions)
    
    @user_begin_time = params[:begin_time]
    @user_end_time = params[:end_time]
    if !@user_end_time.blank? && !@user_begin_time.blank?
      @end_time = UtilityHelper.user_time_zone_to_utc(@user_end_time)
      @begin_time = UtilityHelper.user_time_zone_to_utc(@user_begin_time)
      @events = Event.find(:all, :conditions => ["timestamp >= ? AND timestamp <= ? and id IN (?)", @begin_time, @end_time,@events])
    end
    
    @users = User.halousers.collect{|u| u.id}
    @all_events = []
    @events = @events.collect{|event| event if !event.call_center_response.nil? and ((event.call_center_response.to_time - event.timestamp.to_time) >= params[:response_time].to_f)} if !params[:response_time].blank?
    @events = @events.reject{|t| t.nil?}
    @events = @events.collect{|event| event if event.timestamp_server and ((event.timestamp_server.to_time - event.timestamp.to_time) >= params[:server_delay].to_f)} if !params[:server_delay].blank?
    @events = @events.reject{|t| t.nil?}
    @events = @events.collect{|event| event if !event.event.timestamp_call_center.nil? and ((event.event.timestamp_call_center.to_time - event.event.timestamp_server.to_time) >= params[:call_center_delay].to_f)} if !params[:call_center_delay].blank?
    @events = @events.reject{|t| t.nil?}
    
    @events = event_classification(@events) if params[:commit]
    
    @users = params[:user_id] if params[:user_id] and !params[:user_id].blank?
    @my_events = Event.find(:all,:conditions => ["id IN (?) and user_id IN (?)",@events,@users])
    @events = Event.paginate :page => params[:page], :order => "(timestamp_server IS NOT NULL) DESC, timestamp_server DESC, timestamp DESC", :conditions => ["id IN (?) and user_id IN (?)",@events,@users], :per_page => events_per_page
    
  end 
  
  def set_checkbox_conditions
  	cond = '('
  	cond += params[:fall] ? "event_type = 'Fall'" : ''
  	cond += (params[:fall] and params[:panic]) ? " or " : ''
  	cond += params[:panic] ? "event_type = 'Panic'" : ''
  	if params[:gwreset_button] and !params[:fall] and !params[:panic]
  	  cond +=  "event_type = 'GwAlarmButton'"
  	elsif params[:gwreset_button]
  	  cond += " or event_type = 'GwAlarmButton'"	
  	end
  	cond += ')'
    cond
  end
  
  def event_classification(events)
  	total_events = []
    total_events += events.collect{|event| event if event.real_alarm?}.uniq if params[:real]
    total_events += events.collect{|event| event if event.ems?}.uniq if params[:ems]
  	total_events += events.collect{|event| event if event.false_alarm?}.uniq if params[:false]
  	total_events += events.collect{|event| event if event.test_alarm?}.uniq if params[:test]
  	total_events += events.collect{|event| event if event.gw_reset?}.uniq if params[:gw_reset]
  	total_events += events.collect{|event| event if event.non_emerg_panic?}.uniq if params[:non_emergency]
  	total_events += events.collect{|event| event if event.unclassified?}.uniq if params[:unclassified]
  	total_events += events.collect{|event| event if event.duplicate?}.uniq if params[:unclassified]
  	total_events.uniq.reject{|t| t.nil?}
  end
  
  def faq
    @faq = CallCenterFaq.find(:first, :order => 'updated_at desc')
  end
  
  def faq_edit
    if(current_user.is_super_admin?)
      @faq = CallCenterFaq.find(:first, :order => 'updated_at desc')
      unless @faq
        @faq = CallCenterFaq.new
      else
        @id = @faq.id
      end
    else
      redirect_to :action => 'faq'
    end
  end
  
  def faq_save
    if(current_user.is_super_admin?)
      if !params[:call_center_faq_id].blank?
        @faq = CallCenterFaq.find(params[:call_center_faq_id])
        @faq.faq_text = params[:faq][:faq_text]
      else
        @faq = CallCenterFaq.new(:faq_text => params[:text])
      end
      @faq.updated_by = current_user.id
      @faq.save!
    end
    redirect_to :action => 'faq'
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

  def test_alarm
    @event = Event.find(params[:id])
    
    action = EventAction.new
    action.user_id = current_user.id
    action.event_id = params[:id]
    action.description = 'test_alarm'
    action.save!
    ea = action      
    
    render :partial => 'test_alarm', :locals => {:event => Event.find(params[:id])}
  end
  
  def false_alarm
    @event = Event.find(params[:id])
    
    action = EventAction.new
    action.user_id = current_user.id
    action.event_id = params[:id]
    action.description = 'false_alarm'
    action.save!
    ea = action      
    
    render :partial => 'false_alarm', :locals => {:event => Event.find(params[:id])}
  end
  
  def real_alarm
    @event = Event.find(params[:id])
    
    action = EventAction.new
    action.user_id = current_user.id
    action.event_id = params[:id]
    action.description = 'real_alarm'
    action.save!
    ea = action      
    
    render :partial => 'real_alarm', :locals => {:event => Event.find(params[:id])}
  end
  
  def gw_reset
    @event = Event.find(params[:id])
    
    action = EventAction.new
    action.user_id = current_user.id
    action.event_id = params[:id]
    action.description = 'gw_reset'
    action.save!
    ea = action
    
    render :partial => 'gw_reset', :locals => {:event => Event.find(params[:id])}
  end
  
  def ems
    @event = Event.find(params[:id])
    
    action = EventAction.new
    action.user_id = current_user.id
    action.event_id = params[:id]
    action.description = 'ems'
    action.save!
    ea = action
    
    render :partial => 'ems', :locals => {:event => Event.find(params[:id])}
  end  
  
  def non_emerg_panic
    @event = Event.find(params[:id])
    
    action = EventAction.new
    action.user_id = current_user.id
    action.event_id = params[:id]
    action.description = 'non_emerg_panic'
    action.save!
    ea = action      
    
    render :partial => 'non_emerg_panic', :locals => {:event => Event.find(params[:id])}
  end
  
  def duplicate_event
  	@event = Event.find(params[:id])
  	if params[:textfield]
      render :partial => 'duplicate_event', :locals => {:event => Event.find(params[:id]),:textfield => params[:textfield]}
    else
      action = EventAction.new
      action.user_id = current_user.id
      action.event_id = params[:id]
      action.description = 'duplicate'
      action.save!
      ea = action 
      @event.update_attributes(:duplicate_id => params[:duplicate_event])
      render :partial => 'duplicate_event', :locals => {:event => Event.find(params[:id])}
	end 


  end
  
  def undo_action
  	@event = Event.find(params[:id])
  	@event.update_attributes(:duplicate_id => nil)
    @event_action = EventAction.find_by_event_id(params[:id])
    @event_action.destroy
    render :partial => 'mark_event',:locals => {:event => Event.find(params[:id])}
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
    if @call_center_step.nil?
      @call_center_step = CallCenterStep.new(:header => CallCenterWizard::THE_END,
                                              :script => "Please click <a style=\"color: white;\" href=\"/call_center/resolved/#{@event.id}\">here to Resolve</a> the event.",
                                              :instruction => CallCenterWizard::THE_END)
    end
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
      page.call 'update_accordian', "#{@call_center_step.id}","", ""
      page.call 'update_notes', "#{@call_center_step.id}", "", ""
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
    if CallCenterWizard::THE_END == @call_center_step.question_key || CallCenterWizard::THE_END == @call_center_step.header
      action = EventAction.new
      action.user_id = current_user.id
      action.event_id = @event.id
      action.description = 'resolved'
      action.save!
      send_admin_call_log_email()
       @call_center_step = CallCenterStep.new(:header => CallCenterWizard::THE_END,
                                                :script => "<div style=\"font-size: 150%; color: white;\">The event is now resolved.</div>",
                                                :instruction => CallCenterWizard::THE_END)
        GwAlarmButton.find(:first, :conditions => "timestamp < '#{Time.now.to_s}' AND timestamp > '#{@event.timestamp.to_s}'", 
                            :order => 'timestamp desc')
        #spawn deferred
        device_id = nil
        @user.devices.each do |d|
          if d.device_type == 'Gateway'
            device_id = d.id
          end
        end
        event = @event
        if @event.event_type == CallCenterFollowUp.class_name
          event = get_original_event(@event)
        end
        deferred = CallCenterDeferred.create(:pending => true, 
                                              :device_id => device_id, 
                                              :user_id => @user.id,
                                              :event_id => event.id,
                                              :timestamp => Time.now,
                                              :call_center_session_id => @call_center_session.id)
        spawn do
          sleep(GW_RESET_BUTTON_FOLLOW_UP_TIMEOUT) 
          RAILS_DEFAULT_LOGGER.warn("spawn Checking CallCenterDeferred: #{deferred.id}")
          deferred = CallCenterDeferred.find(deferred.id)
          if deferred && deferred.pending
            CallCenterFollowUp.create(:device_id => deferred.device_id,
            :user_id => deferred.user_id,
            :event_id => deferred.event_id,
            :timestamp => Time.now,
            :call_center_session_id => deferred.call_center_session_id)
          end
        end
    end
      render(:update) do |page|
        page.call 'update_accordian', "#{previous_step.id}","#{previous_step.instruction}", "#{ans}"
        page << "accordion.step(#{@call_center_step.id});"
        page['call_center-wizard'].replace_html render(:partial => 'script', :layout => false)
      end
    
  end
  
  def script_note_save
    @call_center_step = CallCenterStep.find(params[:step_id])
    @call_center_step.notes = params[:script_note]
    @call_center_step.save!
    render(:update) do |page|
      
      page.call 'update_notes', "#{@call_center_step.id}", "<div>" + "#{ h @call_center_step.notes}" + "</div>", "<hr />"
                    page['notes_text'].replace_html "#{h @call_center_step.notes}<br /><a href=\"#\" onclick=\"$('notes_text').hide();$('notes').show();\">Edit Notes</a>"
                    page['notes'].hide();
                    page['notes_text'].show();
      
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
  
  def event_details
  	@event = Event.find_by_id(params[:id])
  end
  
  def show
    @user = current_user
    @groups = []
      if @user.is_super_admin?
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
  
  def report
    @event = Event.find(params[:id])
    @session = @event.call_center_session
  end
  
  def call_center_response
    @event = Event.find(params[:id])
    #UtilityHelper.format_datetime(params[:call_center_response].to_time,current_user)
     @response_time = UtilityHelper.user_time_zone_to_utc(params[:call_center_response])
     @timestamp = UtilityHelper.user_time_zone_to_utc(@event.timestamp_server.to_s)
    if @timestamp < @response_time
      @event.update_attributes(:call_center_response => params[:call_center_response])
      render :update do |page|
        page.replace_html 'div_' +@event.id.to_s, :partial => 'call_center_response'
        page.replace_html 'div_response_' +@event.id.to_s, :partial => 'response_time'
      end
    else
      render :update do |page|
        page.replace_html 'div_' +@event.id.to_s, :partial => 'call_center_response'
        page.replace_html 'div_response_' +@event.id.to_s, '<font color="red">"Call Center Response" must be later then "Timestamp Server"</font>'
      end
    end
  end
  
  def enter_call_center_response
    @event = Event.find(params[:id])
    render :update do |page|
      page.replace_html 'div_' +@event.id.to_s, :partial => 'enter_call_center_response'
    end
  end
  
  def edit_call_center_response
    @event = Event.find(params[:id])
    render :update do |page|
      page.replace_html 'div_' +@event.id.to_s, :partial => 'edit_call_center_response'
      page.replace_html 'div_response_' +@event.id.to_s, :partial => 'response_time'
    end
  end
  ###############################################
  private
  ###############################################
  
  def send_admin_call_log_email()
    body = ""
    steps = @call_center_wizard.call_center_session.call_center_steps.sort do |a, b|
      a.updated_at <=> b.updated_at
    end
    steps.each do |step|
      if !step.answer.blank?
        body << "\n\n#{UtilityHelper.format_datetime(step.updated_at, @user)}\n#{step.instruction}  \n#{step.answer}  \n#{step.notes}"
      end
    end
      accepted_time = UtilityHelper::seconds_format((@event.accepted?.created_at - @event.timestamp).seconds)
      resolved_time = UtilityHelper::seconds_format((@event.resolved?.created_at - @event.accepted?.created_at).seconds)
      total_time = UtilityHelper::seconds_format((@event.resolved?.created_at - @event.timestamp).seconds)
      body << "\n\n #{accepted_time} from event to accepted"
      body << "\n #{resolved_time} from accepted to resolved"
      body << "\n #{total_time} from event to resolved"
      # recipients = User.super_admins()
      #       groups = @user.group_memberships
      #       admins = User.administrators()
      #       admins.each do |admin|
      #         if admin.is_admin_of_any?(groups)
      #           recipients << admin
      #         end
      #       end
      CriticalMailer.deliver_admin_call_log(@event, body, [current_user])
  end
  
  def get_original_event(event)
    follow_up = CallCenterFollowUp.find(event.event_id)
    event_type = follow_up.event.event_type
    if event_type == CallCenterFollowUp.class_name
      event_type = get_event_type(follow_up.event)
    else
      return event_type
    end
  end
end
