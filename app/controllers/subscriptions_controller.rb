class SubscriptionsController < ApplicationController

  def show
  	@subscription = Subscription.find(params[:id])
  end

end
