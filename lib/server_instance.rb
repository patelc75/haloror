module ServerInstance
  @@hosts = ["sdev", "idev", "ldev", "dev"]
  
  def self.current_host
    if Thread.current[:host].nil?
      @prefix = "RUFUS "
      `hostname`.strip
    else
      @prefix = ""
      Thread.current[:host]
    end
  end
  
  def self.current_host=(host)
    Thread.current[:host] = host
  end
  
  def self.current_host_short_string()
    @@hosts.each do |host|
      if in_hostname? host
        return @prefix + host.upcase
      end
    end
    
    if in_hostname? "com"
      @prefix + "HALO"  
    else
      @prefix + current_host
    end
  end
  
  def self.in_hostname? string    
    current_host.split('.').include? string
  end
end
