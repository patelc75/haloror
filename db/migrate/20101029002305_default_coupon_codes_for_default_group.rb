class DefaultCouponCodesForDefaultGroup < ActiveRecord::Migration
  def self.up
    # find or create group
    _group = Group.default!

    # find myhalo_complete if exists
    _coupon = _group.coupon_codes.first( :conditions => { 
      :device_model_id => DeviceModel.myhalo_complete.id, :coupon_code => "default" })
      # create when not found
      # use defaults
    _group.coupon_codes.create( {
      :coupon_code => "default",
      :device_model_id => DeviceModel.myhalo_complete.id,
      :expiry_date => "2015-07-23",
      :deposit => 99,
      :shipping => 16,
      :monthly_recurring => 59,
      :months_advance => 1,
      :months_trial => 0 
    } ) if _coupon.blank?
    
    # myhalo_clip, find if exists
    _coupon = _group.coupon_codes.first( :conditions => {
      :device_model_id => DeviceModel.myhalo_clip.id, :coupon_code => "default" })
    # create when not found
    # use defaults
    _group.coupon_codes.create( {
      :coupon_code => "default",
      :device_model_id => DeviceModel.myhalo_clip.id,
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
