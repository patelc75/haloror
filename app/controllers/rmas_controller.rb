class RmasController < ApplicationController

  def index
  	
  	if current_user.is_super_admin?
      @groups = Group.find(:all)
	else
      @groups = current_user.group_memberships
    end
    
  	cond = "1=1"
  	search = params[:search]
  	cond += " and user_id = #{search} or phone_number like '%#{search}%'" if search and !search.blank?
  	cond += " and group_id = #{params[:group][:id]}" if params[:group] and !params[:group][:id].blank?
    @rmas = Rma.paginate :page => params[:page],:order => 'created_at desc',:per_page => 20,:conditions => cond
  end

  def new
  	@rma = Rma.new
  	if current_user.is_super_admin?
      @groups = Group.find(:all)
	else
      @groups = current_user.group_memberships
    end
  end

  def create
  	@rma = Rma.new(params[:rma])
  	@rma.created_by = current_user.id
  	if @rma.save
  		redirect_to rmas_path
  	else
  		render :action => 'new'
  	end
  	
  end

  def show
  	@rma = Rma.find params[:id]
  end

end
