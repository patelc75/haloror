class GatewayPassword < ActiveRecord::Base
  belongs_to :device
  def self.generate_password(serial_number)
    gateway = Device.find_by_serial_number(serial_number)
    if gateway
      pass = self.random_password
      gp = GatewayPassword.find_by_device_id(gateway.id)
      if gp
        gp.update_attributes(:password => User.encrypt(pass, gp.salt))
      else
        salt = generate_salt(serial_number)
        gp = GatewayPassword.new(:salt => salt, :password =>  User.encrypt(pass, salt), :device_id => gateway.id)
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
  def self.generate_salt(serial_number)
    salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{serial_number}--")
    return salt
  end
end