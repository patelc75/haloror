class CallCenterAcceptController < ApplicationController
  def accept
    timestamp = params[:timestamp].to_time
    user_id = params[:user_id]
    operator_id = params[:operator_id]
    description = params[:description]
    
    event = Event.find(:first, :conditions => "timestamp = '#{timestamp.to_s(:db)}' AND user_id = #{user_id}")
    if event
      event_action = event.accepted?
      if !event_action
        action = EventAction.new
        action.user_id = operator_id
        action.event_id = event.id
        action.description = description
        action[:send_email] = false
        action.save!   
      end
    end
    render :text => ''
  end
end