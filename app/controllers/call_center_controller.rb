class CallCenterController < ApplicationController
  def index
    @events = Event.find(:all)
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
end
