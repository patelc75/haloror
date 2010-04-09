class AddRowsToDeviceModelPrices < ActiveRecord::Migration
  def self.up
  	device_model = DeviceModel.find(:first, :conditions => {:part_number => "12001002-1"})
  	if device_model
  	DeviceModelPrice.create(:device_model_id => device_model.id, :coupon_code => "", :deposit => 249, :shipping => 15, :monthly_recurring => 59, :months_advance => 3, :months_trial => 0)
  	DeviceModelPrice.create(:device_model_id => device_model.id, :coupon_code => "99TRIAL",:deposit => 99,:shipping => 15,:monthly_recurring => 59,:months_advance => 0, :months_trial => 1)
  	end
  	
  	device_model_id = DeviceModel.find(:first, :conditions => {:part_number => "12001008-1"})
  	if device_model_id
  	DeviceModelPrice.create(:device_model_id => device_model_id.id, :coupon_code => "", :deposit => 249, :shipping => 15, :monthly_recurring => 59, :months_advance => 3, :months_trial => 0)
  	DeviceModelPrice.create(:device_model_id => device_model_id.id, :coupon_code => "99TRIAL",:deposit => 99,:shipping => 15,:monthly_recurring => 59,:months_advance => 0, :months_trial => 1)
  	end
  end

  def self.down
  end
end
