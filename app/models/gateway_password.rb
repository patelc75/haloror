require 'aes_crypt'
class GatewayPassword < ActiveRecord::Base
  belongs_to :device
  def self.generate_password(serial_number)
    gateway = Device.find_by_serial_number(serial_number)
    if gateway
      pass = self.random_password
      gp = GatewayPassword.find_by_device_id(gateway.id)
      if gp
        gp.update_attributes(:password => AESCrypt.encrypt(pass, gp.salt, nil, 'AES-256-ECB'))
      else
        salt = generate_salt(serial_number)
        gp = GatewayPassword.new(:salt => salt, :password =>  AESCrypt.encrypt(pass, salt, nil, 'AES-256-ECB'), :device_id => gateway.id)
      end
      gp.save!
      return pass
    else
      return nil
    end
  end
  def self.retrieve_password(serial_number)
    device = Device.find_by_serial_number(serial_number)
    if device
      gp = GatewayPassword.find_by_device_id(device.id)
      if gp
        return AESCrypt.decrypt(gp.password, gp.salt, nil, 'AES-256-ECB')
      else
        #no password found
        raise "No Gateway Password Found"
      end
    else
      #device not found
      raise "Device Not Found"
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