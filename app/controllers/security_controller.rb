class SecurityController < ApplicationController
  def index
  end
  
  def unauthorized
    
  end
  def is_admin
    if current_user && current_user != :false && current_user.is_super_admin?()
      render :text => 'true'
    else
      render :text => 'false'
    end
  end
end