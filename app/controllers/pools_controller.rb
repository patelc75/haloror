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
    serial_numbers = []
    last_serial_number = get_last_serial_number(pool) + 1
    (0..pool.size-1).each do |i|
      num = i + last_serial_number
      serial_numbers << get_serial_number(pool, num)
    end
    #Mac Adrress Generation
    mac_addresses = []
    last_mac_address = get_last_mac_address(pool) + 1
    (0..pool.size-1).each do |i|
      num = i + last_mac_address
      mac_addresses << get_mac_address(pool, num)
    end
    Device.transaction do
      (0..pool.size-1).each do |i|
        device = Device.new(:active => false, :pool_id => pool.id, :serial_number => serial_numbers[i], :mac_address => mac_addresses[i])
        device.save!
      end
      pool.ending_serial_number = serial_numbers[pool.size - 1]
      pool.ending_mac_address = mac_addresses[pool.size - 1]
      pool.save!
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
    end_num = num.to_s(16)
    mac_address = pool.starting_mac_address
    mac_address = mac_address.ljust(12, "0")
    mac_address[mac_address.size - end_num.size, mac_address.size]= end_num
    mac_address = mac_address[0,2] + ':' + mac_address[2, 2] + ':' + mac_address[4,2] + ':' + mac_address[6,2] + ':' + mac_address[8,2] + ':' + mac_address[10,2]
    return mac_address
  end
  
  def is_zigby?(pool)
    dt = DeviceType.find(:first, :conditions => "serial_number_prefix = '#{pool.starting_serial_number[0,2]}'")
    return dt.is_zigby_device
  end
  def get_last_mac_address(pool)
    pools = []
    num = -1
    if(is_zigby?(pool))
      #num needs to start at hex 80:01:00
      num = '800000'.hex
      dts = DeviceType.find(:all, :conditions => "is_zigby_device = true")
      conds = []
      dts.each do |dt|
        conds << "starting_serial_number like '#{dt.serial_number_prefix}%'"
      end
      conds = conds.join(' OR ')
      pools = Pool.find(:all, :conditions => conds)
    else
      pools = Pool.find(:all, :conditions => "starting_serial_number like '#{pool.starting_serial_number[0,2]}%'")
    end
    
    if pools && pools.size > 1
      pools.each do |p|
        if p.ending_mac_address
          last_num = get_last_mac_num(p.ending_mac_address)
        end
        if last_num && last_num > num
          num = last_num
        end
      end
    end
    return num
  end
  
  def get_last_mac_num(mac)
    num = mac.gsub(':', '')[6,6].hex
    return num
  end
  
  def get_last_serial_number(pool)
    pools = Pool.find(:all, :conditions => "starting_serial_number like '#{pool.starting_serial_number[0,2]}%'")
    num = -1
    if pools && pools.size > 1
      pools.each do |p|
        if p.ending_serial_number
          last_num = get_last_num(p.ending_serial_number)
        end
        if last_num && last_num > num
          num = last_num
        end
      end
    end
    return num
  end
  
  def get_last_num(sn)
    sn = sn[5,5]
    sn = sn.to_i
    return sn
  end
end
