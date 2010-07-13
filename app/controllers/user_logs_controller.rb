class UserLogsController < ApplicationController
  def index
    @user = User.find(params[:user_id])
    @user_logs = @user.logs.paginate :page => params[:page], :per_page => 20
  end

  def show
    @user_log = UserLog.find(params[:id])
    # @user = @user_log.user
  end

end
