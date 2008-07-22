module ServerInstance
  @@hosts = ["sdev", "idev", "ldev", "dev"]
  
  def self.current_host
    Thread.current[:host]
  end
  
  def self.current_host=(host)
    Thread.current[:host] = host
  end
  
  def self.current_host_short_string()
    @@hosts.each do |host|
      if in_hostname? host
        return host.upcase
      end
    end
    "HALO"
  end
  
  def self.in_hostname? string
    current_host.split('.').include? string
  end
end
