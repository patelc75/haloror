class PurgedLogsController < ApplicationController

  def index
  	@purged_logs = PurgedLog.paginate :page => params[:page], :per_page => 20, :order => 'created_at'
  end

end
