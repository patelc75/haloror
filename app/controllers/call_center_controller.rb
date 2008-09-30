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
    # event = Event.find(params[:id])
    #    event.accepted_by = current_user.id
    #    event.accepted_at = Time.now
    #    event.save
    
    action = EventAction.new
    action.user_id = current_user.id
    action.event_id = params[:id]
    action.description = 'accepted'
    action.save
    
    render :partial => 'accept', :locals => {:event => Event.find(params[:id])}
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
    @operators = User.operators
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
end
