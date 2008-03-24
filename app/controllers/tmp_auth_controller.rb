class TmpAuthController < ApplicationController
  def administrator
    current_user.has_role 'administrator'
    
    render :nothing => true
  end
end
