class RmasController < ApplicationController

  # TODO: re-factoring required
  def index
    @groups = Group.all # current_user.group_memberships # https://redmine.corp.halomonitor.com/issues/2925

    options = {}
    # cond = "1=1"
    @search = params[:search]
    # # cond += " and user_id = #{search} or phone_number like '%#{search}%'" if search and !search.blank?
    # # cond += " and group_id = #{params[:group][:id]}" if params[:group] and !params[:group][:id].blank?
    # options[:conditions] = if search.blank?
    #   {}
    # else
    #   phrases = search.split(',').collect(&:strip).each do |phrase|
    #     ["rmas.user_id = ? OR rmas.serial_number LIKE ? OR rmas.status LIKE ?", search.to_i, "%#{search}%", "%#{search}%"]
    #   end
    # end
    #
    # decide the column sort order
    unless ( sort = params[:sort]).blank?
      case sort.split(' ')[0]
      when 'group'
        options[:include] = [ :user, :group]
        options[:order] = "groups.name #{params[:sort].split(' ')[1]}"
      end
    end
    options.merge( :include => :user) unless options.include?( :include)
    options.merge( :order => 'created_at DESC') unless options.include?( :order)
    @rmas = if @search.blank?
      Rma.all( options)
    else
      ["user_id", "user", "serial_number", "status"].collect {|e| Rma.send( :"#{e}_like", @search) }.flatten.uniq
    end
    @rmas = @rmas.paginate :page => params[:page], :per_page => 20

    respond_to do |format|
      format.html
    end
  end

  def new
  	@rma = Rma.new
    @groups = Group.all # current_user.group_memberships

    respond_to do |format|
      format.html
    end
  end

  def create
    @rma = Rma.new(params[:rma])
    @rma.created_by = current_user.id
    @groups = Group.all # current_user.group_memberships

    respond_to do |format|
      if @rma.save
        flash[:notice] = 'RMA was successfully saved.'
        format.html { redirect_to(:action => 'show', :id => @rma.id) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def edit
    @rma = Rma.find(params[:id])
    @groups = Group.all # current_user.group_memberships
    
    respond_to do |format|
      format.html
    end
  end  
  
  def update
    @rma = Rma.find(params[:id])
    @groups = Group.all # current_user.group_memberships

    respond_to do |format|
      if @rma.update_attributes(params[:rma])
        flash[:notice] = 'RMA was successfully updated.'
        format.html { redirect_to(:action => 'show', :id => @rma.id) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit", :id => @rma.id }
        format.xml  { render :xml => @rma.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def show
  	@rma = Rma.find params[:id]
  end
  
  def destroy
    @rma = Rma.find(params[:id])
    @rma.destroy

    respond_to do |format|
      format.html { redirect_to(:action => 'index') }
      format.xml  { head :ok }
    end
  end
end
