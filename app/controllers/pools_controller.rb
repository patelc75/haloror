class PoolsController < ApplicationController
  def index
    @pools = Pool.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @pools }
    end
  end

  def show
    @pool = Pool.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @pool }
    end
  end

  def new
    @pool = Pool.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @pool }
    end
  end

  def edit
    @pool = Pool.find(params[:id])
  end

  def create
    @pool = Pool.new(params[:pool])
    @pool.starting_mac_address = '002440'
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

  private
  
  #calculate the input pool's starting and ending serial num and mac address starting from the exisiting pools (in pools table)
  #most recent ending_serial_num and ending_mac_address. Starts at xxxxx00100 if no existing pools. Also, creates new rows in 
  #devices table for the size of the pool
  def generate_serial_number_mac_address_mappings(pool)
    start_serial_number = pool.starting_serial_number
    start_mac_address   = pool.starting_mac_address
    
    #generate array (serial_numbers), one serial number per row based on size of pool
    serial_numbers = []
    last_serial_number = get_last_serial_number(pool) + 1    
    (0..pool.size-1).each do |i| 
      num = i + last_serial_number
      serial_numbers << get_serial_number(pool, num)
    end
    
    #generate array (mac_addresses), one mac address per row based on size of pool
    mac_addresses = []
    last_mac_address = 0
    if is_zigbee?(pool) || is_gateway?(pool) #checks device_type.mac_address_type (zigbee = 0, gateway = 1)
      last_mac_address = get_last_mac_address(pool) + 1
    end
    
    (0..pool.size-1).each do |i|
      num = i + last_mac_address
      if is_zigbee?(pool) || is_gateway?(pool)
        mac_addresses << get_mac_address(pool, num)
      else
        mac_addresses << ''
      end
    end
    
    #add a new device for each row in the pool and save the pool
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
  
  #utility method to generate the serial number string
  def get_serial_number(pool, num)
    end_num = num.to_s
    serial_number = pool.starting_serial_number
    serial_number = serial_number.ljust(10, "0")
    serial_number[serial_number.size - end_num.size, serial_number.size]= end_num
    RAILS_DEFAULT_LOGGER.warn(serial_number)
    return serial_number
  end

  #utility method to generate the mac addr string  
  def get_mac_address(pool, num)
    end_num = num.to_s(16)
    # mac_address = pool.starting_mac_address
    mac_address = '002440'
    mac_address = mac_address.ljust(12, "0")
    mac_address[mac_address.size - end_num.size, mac_address.size]= end_num
    mac_address = mac_address[0,2] + ':' + mac_address[2, 2] + ':' + mac_address[4,2] + ':' + mac_address[6,2] + ':' + mac_address[8,2] + ':' + mac_address[10,2]
    return mac_address
  end

  #returns true if device_type.serial_number_prefix.mac_address_type = 0
  def is_zigbee?(pool)
    dt = DeviceType.find(:first, :include => :serial_number_prefixes, 
                        :conditions => "serial_number_prefixes.prefix = '#{pool.starting_serial_number[0,3]}'")
    if dt.nil?
      throw "no row in serial_number_prefixes table for prefix #{pool.starting_serial_number[0,3]}"
    else
      return dt.mac_address_type == 0
    end
  end
  
  #returns true if device_type.serial_number_prefix.mac_address_type = 1
  def is_gateway?(pool)
    dt = DeviceType.find(:first, :include => :serial_number_prefixes, 
                        :conditions => "serial_number_prefixes.prefix = '#{pool.starting_serial_number[0,3]}'")
    if dt.nil?
      throw "no row in serial_number_prefixes table for prefix #{pool.starting_serial_number[0,3]}"
    else
      return dt.mac_address_type == 1
    end
  end

  #get the ending mac addr by looping through all pools with the starting_serial_number 
  #(the prefix) matching the input pool's starting_serial_number  
  def get_last_mac_address(pool)
    pools = []
    num = -1
    if(is_zigbee?(pool))
      #num needs to start at hex 80:01:00
      num = '800000'.hex - 1
      dts = DeviceType.find(:all, :conditions => "mac_address_type = 0")
      conds = []
      dts.each do |dt|
        prefixes = dt.serial_number_prefixes
        prefixes.each do |prefix|
          conds << "starting_serial_number like '#{prefix.prefix}%'"
        end
      end
      conds = conds.join(' OR ')
      pools = Pool.find(:all, :conditions => conds)
    elsif(is_gateway?(pool))
      dts = DeviceType.find(:all, :conditions => "mac_address_type = 1")
      conds = []
      dts.each do |dt|
        prefixes = dt.serial_number_prefixes
        prefixes.each do |prefix|
          conds << "starting_serial_number like '#{prefix.prefix}%'"
        end
      end
      conds = conds.join(' OR ')
      pools = Pool.find(:all, :conditions => conds)
    else
        dts = DeviceType.find(:all, :conditions => "mac_address_type = 2")
        conds = []
        dts.each do |dt|
          prefixes = dt.serial_number_prefixes
          prefixes.each do |prefix|
            conds << "starting_serial_number like '#{prefix.prefix}%'"
          end
        end
        conds = conds.join(' OR ')
        pools = Pool.find(:all, :conditions => conds)      
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
  
  #returns last 6 chars of input mac addr (mac)
  def get_last_mac_num(mac)
    num = mac.gsub(':', '')[6,6].hex
    return num
  end
  
  #get the ending serial number by looping through all pools with the starting_serial_number 
  #(the prefix) matching the input pool's starting_serial_number
  def get_last_serial_number(pool)
    pools = Pool.find(:all, :conditions => "starting_serial_number like '#{pool.starting_serial_number}%'")
    num = 99
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
  
  #returns last 5 chars of the input serial number (sn)
  def get_last_num(sn)
    sn = sn[5,5]
    sn = sn.to_i
    return sn
  end
end
