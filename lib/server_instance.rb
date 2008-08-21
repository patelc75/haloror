module ServerInstance
  @@prefixes = ["crit2", "sdev", "idev", "ldev", "dev", "atl-web1"]
  
  def self.current_host
    if Thread.current[:host].nil?
      `hostname`.strip
    else
      Thread.current[:host]
    end
  end
  
  def self.current_host=(host)
    Thread.current[:host] = host
  end
  
  def self.current_host_short_string()
    @@prefixes.each do |prefix|
      if in_hostname? prefix
        return prefix.upcase
      end
    end
    
    in_hostname?("com") ? "HALO" : current_host
  end
  
  def self.in_hostname? string    
    current_host.split('.').include? string
  end
end
