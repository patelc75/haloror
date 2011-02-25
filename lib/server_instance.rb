module ServerInstance
  @@prefixes = ["crit2", "sdev-crit2", "sdev", "idev", "ldev", "dev", "cdev", "atl-web1"]
  
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
  
  # 
  #  Sat Feb 26 01:31:05 IST 2011, ramonrails
  #   * https://redmine.corp.halomonitor.com/issues/4223
  #   Usage:
  #   * ServerInstance.host?( "host.local", "ATL-WEB1") => true (if current host is among any of these)
  def self.host?( *_name )
    (_name.blank? || !_name.is_a?(Array)) ? false : (_name.any? {|e| e == self.current_host_short_string })
  end
end
