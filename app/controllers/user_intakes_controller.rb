class UserIntakesController < ApplicationController

  def index
    @user_intakes = UserIntake.paginate :page => params[:page],:order => 'created_at desc',:per_page => 20
  end
  
end
