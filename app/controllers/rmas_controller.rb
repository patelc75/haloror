class RmasController < ApplicationController

  # TODO: re-factoring required
  def index
    @groups = Group.all # current_user.group_memberships # https://redmine.corp.halomonitor.com/issues/2925

    options = {}
    # cond = "1=1"
    #
    # dynamically create instance variables, used to show selection on form
    @search = params[:search]
    # status search
    #   no status check_box "on" ? what are we searching then?
    params[:status] = RmaItemStatus::STATUSES if params[:status].blank? # switch them all "on"
    params[:status].each {|e| instance_variable_set("@rma_#{e[0].downcase.gsub(' ','_')}", e[0]) }
    statuses = params[:status].collect(&:first) # collect status names in array. we will use it to filter later
    sort = params[:sort] # sort parameter
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
    # # decide the column sort order
    # unless ( sort = params[:sort]).blank?
    #   case sort.split(' ')[0]
    #   when 'group'
    #     options[:include] = [ :user, :group]
    #     options[:order] = "groups.name #{params[:sort].split(' ')[1]}"
    #   end
    # end
    options.merge( :include => :user) unless options.include?( :include)
    # Search:
    # we are not using a default sort order now. we will sort the results in memory
    # options.merge( :order => 'created_at DESC') unless options.include?( :order)
    @rmas = if @search.blank?
      Rma.all( options)
    else
      # "status" was part of this query earlier. Now we are using status checkboxes
      ["user_id", "user", "serial_number"].collect {|e| Rma.send( :"#{e}_like", @search) }.flatten.uniq
    end
    # now filter by status. include RMAs with no RMA items
    if statuses.length == RmaItemStatus::STATUSES.length
      @rmas = Rma.all
    else
      @rmas = @rmas.select {|e| !(statuses & e.rma_items.collect(&:status).uniq ).blank? } # we want to see "statuses" collected above
    end
    # Sort:
    # ascending or descending sort based on the supplied argument
    unless sort.blank?
      case sort.split(' ')[0]
      when "group" # sort by group required
        @rmas = @rmas.sort {|a,b| ( sort.split(' ')[1].include?("asc") ? (a.group_name <=> b.group_name) : (b.group_name <=> a.group_name)) } # sort array
      end
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
