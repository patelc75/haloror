class RedirectorController < ApplicationController

  def index
    if(current_user.is_moderator? || current_user.is_admin? || current_user.is_super_admin?)
      redirect_to :controller => 'reporting', :action => 'users'
    elsif(current_user.is_operator?)
      redirect_to :controller => 'call_center', :action => 'index'
    else
      redirect_to :controller => 'chart', :action => 'flex'
    end
  end
end