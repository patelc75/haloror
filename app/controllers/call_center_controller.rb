class CallCenterController < ApplicationController
  include UtilityHelper
  
  def index
    events_per_page = 25
    conditions = "event_type = 'Fall' or event_type = 'Panic'"
    @events = Event.paginate :page => params[:page], :order => "timestamp DESC", :conditions => conditions, :per_page => events_per_page
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
      render :text => '', :layout => false
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
    user_id = params[:id]
    @notes = Note.find(:all, :conditions => "user_id = #{user_id}", :order => "created_at desc")
    render :template => 'call_center/all_notes'
  end
  def all_event_notes
    event_id = params[:id]
    @notes = Note.find(:all, :conditions => "event_id = #{event_id}", :order => "created_at desc")
    render :template => 'call_center/all_notes'
  end
end
