class SubscriptionsController < ApplicationController

  def show
  	@subscription = Subscription.find(params[:id])
  end

  def index
    @subscriptions = Subscription.paginate :page => params[:page],:order => 'created_at desc',:per_page => 20
  end

end
