class ConvertAttToCingularAttCarrierInProfile < ActiveRecord::Migration
  def self.up
    cingular = Carrier.find_by_domain("@cingularme.com")
    att = Carrier.find_by_domain("@mmode.com")
    
    profiles = Profile.find_all_by_carrier_id(att.id) if !att.nil?
    if profiles
      profiles.each do |profile|
        profile.carrier_id = cingular.id
        profile.save! 
      end
    end
  end

  def self.down
  end
end
