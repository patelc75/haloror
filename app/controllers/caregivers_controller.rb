class CaregiversController < ApplicationController
  in_place_edit_for :caregiver, :city
  ################## streamlined ######################
  #uncomment for streamlined
  #layout "streamlined"
  #acts_as_streamlined  
  
  ################## active_scaffold ######################
  #  active_scaffold :caregiver
  
  #  active_scaffold :caregiver  do |config|
  #    config.columns = [:id, :first_name, :last_name, :address, :city, :state, :home_phone, :work_phone, :cell_phone, :relationship, :email]
  #  
  #    config.columns[:phone_number].description = "(Format: ###-###-####)"
  #    config.columns[:phone_number].label = "Phone"
  #  
  #    config.create.columns.exclude :id
  #    config.update.columns.exclude :id
  #    config.list.columns.exclude :home_phone, :work_phone, :cell_phone
  #    config.subform.columns = [:first_name, :last_name]
  #  
  #    config.list.sorting = {:last_name => 'ASC'}
  #  
  #    config.nested.add_link "Names", [:aliases]
  #  
  #    config.create.columns.exclude :home_phone, :work_phone, :cell_phone
  #    config.create.columns.add_subgroup "Personal Data" do |group|
  #      group.add(:first_name, :middle_name, :last_name, :phone_number)
  #    end
  #  end
  
  def index
    @caregivers = Caregiver.find(:all)
      
    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @caregivers.to_xml }
    end
  end
  
  
  # GET /caregivers/1
  # GET /caregivers/1.xml
  def show
    @caregiver = Caregiver.find(params[:id])
      
    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @caregiver.to_xml }
    end
  end
  
  # GET /caregivers/new
  def new
    @caregiver = Caregiver.new
  end
  
  # GET /caregivers/1;edit
  def edit
    @caregiver = Caregiver.find(params[:id])
  end
  
  # POST /caregivers
  # POST /caregivers.xml
  def create
    @caregiver = Caregiver.new(params[:caregiver])
      
    respond_to do |format|
      if @caregiver.save
        flash[:notice] = 'Caregiver was successfully created.'
        format.html { redirect_to caregiver_url(@caregiver) }
        format.xml  { head :created, :location => caregiver_url(@caregiver) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @caregiver.errors.to_xml }
      end
    end
  end
  
  # PUT /caregivers/1
  # PUT /caregivers/1.xml
  def update
    @caregiver = Caregiver.find(params[:id])
      
    respond_to do |format|
      if @caregiver.update_attributes(params[:caregiver])
        flash[:notice] = 'Caregiver was successfully updated.'
        format.html { redirect_to caregiver_url(@caregiver) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @caregiver.errors.to_xml }
      end
    end
  end
  
  # DELETE /caregivers/1
  # DELETE /caregivers/1.xml
  def destroy
    @caregiver = Caregiver.find(params[:id])
    @caregiver.destroy
      
    respond_to do |format|
      format.html { redirect_to caregivers_url }
      format.xml  { head :ok }
    end
  end

end
