class DialUpsController < ApplicationController

  def index
    @dial_ups = DialUp.find(:all)
  end

  def new
  	@dial_up = DialUp.new
  end

  def create
  	@dial_up = DialUp.new(params[:dial_up])
  	@dial_up.created_by = current_user.id
  	if @dial_up.save
  	  respond_to do |format|
        format.html {redirect_to :action => 'index'}
  	  end
  	else
  	  respond_to do |format|
        format.html {render :action => 'new'}
  	  end
  	end
  end

  def edit
    @dial_up = DialUp.find(params[:id])
  end
  
  def update
  	@dial_up = DialUp.find(params[:id])
  	respond_to do |format|
      if @dial_up.update_attributes(params[:dial_up])
        format.html {redirect_to :action => 'index'}
      else
      	format.html {render :action => edit,:id => params[:id]}
      end
    end
  end
  
  def destroy
  	@dial_up = DialUp.find(params[:id])
  	@dial_up.destroy
  	respond_to do |format|
  		format.html {redirect_to :action => 'index'}
  	end
  end
  
end
