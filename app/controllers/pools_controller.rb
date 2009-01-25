class PoolsController < ApplicationController
  # GET /pools
  # GET /pools.xml
  def index
    @pools = Pool.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @pools }
    end
  end

  # GET /pools/1
  # GET /pools/1.xml
  def show
    @pool = Pool.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @pool }
    end
  end

  # GET /pools/new
  # GET /pools/new.xml
  def new
    @pool = Pool.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @pool }
    end
  end

  # GET /pools/1/edit
  def edit
    @pool = Pool.find(params[:id])
  end

  # POST /pools
  # POST /pools.xml
  def create
    @pool = Pool.new(params[:pool])
    @pool.created_by = current_user.id
    respond_to do |format|
      if @pool.save
        generate_serial_number_mac_address_mappings(@pool)
        flash[:notice] = 'Pool was successfully created.'
        format.html { redirect_to :action => 'show', :id => @pool.id}
        format.xml  { render :xml => @pool, :status => :created, :location => @pool }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @pool.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /pools/1
  # PUT /pools/1.xml
  # def update
  #     @pool = Pool.find(params[:id])
  # 
  #     respond_to do |format|
  #       if @pool.update_attributes(params[:pool])
  #         flash[:notice] = 'Pool was successfully updated.'
  #         format.html { redirect_to(@pool) }
  #         format.xml  { head :ok }
  #       else
  #         format.html { render :action => "edit" }
  #         format.xml  { render :xml => @pool.errors, :status => :unprocessable_entity }
  #       end
  #     end
  #   end
  
  private
  def generate_serial_number_mac_address_mappings(pool)
    start_serial_number = pool.starting_serial_number
    start_mac_address   = pool.starting_mac_address
    
    #Serial Number Generation
    total = 100
    @pools = Pool.find(:all, :conditions => "starting_serial_number LIKE '#{start_serial_number}%'")
    @pools.each do |p|
      total += p.size
    end
    start_size = total - pool.size + 1
    serial_numbers = []
    (start_size..total).each do |i|
      serial_numbers << get_serial_number(pool, i)
    end
    
    #Mac Adrress Generation
    total = 99
    @pools = Pool.find(:all, :conditions => "starting_mac_address LIKE '#{start_mac_address}%'")
    @pools.each do |p|
      total += p.size
    end
    start_size = total - pool.size + 1
    mac_addresses = []
    (start_size..total).each do |i|
      mac_addresses << get_mac_address(pool, i)
    end
    count = 0
    Device.transaction do
      (0..pool.size - 1).each do |i|
        device = Device.new(:active => false, :serial_number => serial_numbers[i], :mac_address => mac_addresses[i])
        device.save!
      end
    end
  end
  def get_serial_number(pool, num)
    end_num = num.to_s
    serial_number = pool.starting_serial_number
    serial_number = serial_number.ljust(10, "0")
    serial_number[serial_number.size - end_num.size, serial_number.size]= end_num
    RAILS_DEFAULT_LOGGER.warn(serial_number)
    return serial_number
  end
  
  def get_mac_address(pool, num)
    end_num = num.to_s
    mac_address = pool.starting_mac_address
    mac_address = mac_address.ljust(10, "0")
    mac_address[mac_address.size - end_num.size, mac_address.size]= end_num
    return mac_address
  end
end
