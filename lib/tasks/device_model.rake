namespace :device do
  desc "Create default devices, part numbers and prices"
  task :defaults => :environment do
    {
      "Chest Strap" => {
        :part_number => "12001002-1", :tariff => {
        :default => { :coupon_code => "",       :deposit => 249, :shipping => 15, :monthly_recurring => 59, :months_advance => 3, :months_trial => 0},
        :expired => { :coupon_code => "EXPIRED", :deposit => 99, :shipping => 15, :monthly_recurring => 59, :months_advance => 3, :months_trial => 0, :expiry_date => 1.month.ago},
        :trial =>   { :coupon_code => "99TRIAL", :deposit => 99, :shipping => 15, :monthly_recurring => 59, :months_advance => 0, :months_trial => 1, :expiry_date => 1.month.from_now}
        }
      },
      "Belt Clip" => {
        :part_number => "12001008-1", :tariff => {
        :default => { :coupon_code => "",       :deposit => 249, :shipping => 15, :monthly_recurring => 49, :months_advance => 3, :months_trial => 0},
        :expired => { :coupon_code => "EXPIRED", :deposit => 99, :shipping => 15, :monthly_recurring => 49, :months_advance => 3, :months_trial => 0, :expiry_date => 1.month.ago},
        :trial =>   { :coupon_code => "99TRIAL", :deposit => 99, :shipping => 15, :monthly_recurring => 49, :months_advance => 0, :months_trial => 1, :expiry_date => 1.month.from_now}
        }
      }
    }.each do |type, values|
      #
      # we assume the test database blank at all times. We therefore create the data for each scenario
      device_type = DeviceType.find_or_create_by_device_type( type )
      device_model = device_type.device_models.find_or_create_by_part_number( values[:part_number] )
      values[:tariff].each do |coupon_type, prices_hash|
        if device_model.coupon_codes.find_by_coupon_code(prices_hash[:coupon_code]).blank?
          device_model.coupon_codes.create( prices_hash)
        end
      end
    end

  end
end