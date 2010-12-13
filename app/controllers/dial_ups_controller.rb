class DialUpsController < ApplicationController

  def index
    # 
    #  Tue Dec 14 00:07:59 IST 2010, ramonrails
    #   * https://redmine.corp.halomonitor.com/issues/3859
    # # WARNING: Code coverage required : https://redmine.corp.halomonitor.com/issues/2809
    # @groups = current_user.group_memberships # fetch groups
    # @group_name ||= ( params[:group_name] || @groups.first.name || "" rescue "") # selected group
    # @dial_ups = DialUp.where_group_id( @groups.collect(&:id)) # collect IDs
    @dial_ups = DialUp.all( :order, "state, city, phone_number").paginate :per_page => 10, :page => params[:page]
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
  
  def dial_up_num
  	 @global_alt = DialUp.find(:first,:conditions => "order_number = 2  and dialup_type = 'Global'")
     @global_prim = DialUp.find(:first,:conditions => "order_number = 1  and dialup_type = 'Global'")
  end
  
end
