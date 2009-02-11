class GatewayPassword < ActiveRecord::Base
  belongs_to :device
  def self.generate_password(serial_number)
    gateway = Device.find_by_serial_number(serial_number)
    if gateway
      pass = self.random_password
      gp = GatewayPassword.find_by_device_id(gateway.id)
      if gp
        gp.update_attributes(:password => pass)
      else
        gp = GatewayPassword.new(:password => pass, :device_id => gateway.id)
      end
      gp.save!
      return pass
    else
      return nil
    end
  end
  
  private
  def self.random_password
    Digest::SHA1.hexdigest("--#{Time.now.to_s}--")[0,6]
  end
end