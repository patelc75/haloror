class DefaultCouponCodesForDefaultGroup < ActiveRecord::Migration
  def self.up
    # find or create group
    _group = Group.find_or_create_by_name( "default")
    # ensure email address
    _group.update_attributes( :email => "senior_signup@halomonitoring.com") if _group.email != "senior_signup@halomonitoring.com"
    # device model price row = coupon code
    
    # find myhalo_complete if exists
    _coupon = DeviceModelPrice.first( :conditions => {
      :device_model_id => DeviceModel.myhalo_complete, :coupon_code => "default", :group_id => _group })
      # create when not found
      # use defaults
    DeviceModelPrice.create( {
      :coupon_code => "default",
      :group_id => _group,
      :device_model_id => DeviceModel.myhalo_complete,
      :expiry_date => "2015-07-23",
      :deposit => 99,
      :shipping => 16,
      :monthly_recurring => 59,
      :months_advance => 1,
      :months_trial => 0 
    } ) if _coupon.blank?
    
    # myhalo_clip, find if exists
    _coupon = DeviceModelPrice.first( :conditions => {
      :device_model_id => DeviceModel.myhalo_clip, :coupon_code => "default", :group_id => _group })
    # create when not found
    # use defaults
    DeviceModelPrice.create( {
      :coupon_code => "default",
      :group_id => _group,
      :device_model_id => DeviceModel.myhalo_clip,
      :expiry_date => "2015-07-23",
      :deposit => 99,
      :shipping => 16,
      :monthly_recurring => 49,
      :months_advance => 1,
      :months_trial => 0 
    } ) if _coupon.blank?
  end

  def self.down
    # we cannot remove this data. required and mandatory
  end
end
