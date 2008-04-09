class CallCenterController < ApplicationController
  def index
    @events = Event.find(:all)
  end
  
  def accept
    event = Event.find(params[:id])
    event.accepted_by = current_user.id
    event.accepted_at = Time.now
    event.save
    
    render :partial => 'accept', :locals => {:event => event}
  end
  
  def resolve
    event = Event.find(params[:id])
    event.resolved_by = current_user.id
    event.resolved_at = Time.now
    event.save
    
    render :partial => 'resolve', :locals => {:event => event}
  end
end
