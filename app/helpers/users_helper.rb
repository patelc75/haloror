module UsersHelper

 def current_host
    Thread.current[:host]
 end
 
 def self.current_host=(host)
  Thread.current[:host] = host
 end
  
  
end