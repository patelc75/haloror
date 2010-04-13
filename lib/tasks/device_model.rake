namespace :device do
  desc "Create default devices, part numbers and prices"
  task :defaults => :environment do
    {
      "Chest Strap" => {
        :part_number => "12001002-1", :tariff => {
        :default => { :coupon_code => "",       :deposit => 249, :shipping => 15, :monthly_recurring => 59, :months_advance => 3, :months_trial => 0},
        :trial =>   { :coupon_code => "99TRIAL", :deposit => 99, :shipping => 15, :monthly_recurring => 59, :months_advance => 0, :months_trial => 1}
        }
      },
      "Belt Clip" => {
        :part_number => "12001008-1", :tariff => {
        :default => { :coupon_code => "",       :deposit => 249, :shipping => 15, :monthly_recurring => 49, :months_advance => 3, :months_trial => 0},
        :trial =>   { :coupon_code => "99TRIAL", :deposit => 99, :shipping => 15, :monthly_recurring => 49, :months_advance => 0, :months_trial => 1}
        }
      }
    }.each do |type, values|
      #
      # we assume the test database blank at all times. We therefore create the data for each scenario
      device_type = DeviceType.find_or_create_by_device_type( type )
      device_model = device_type.device_models.find_or_create_by_part_number( values[:part_number] )
      values[:tariff].each do |coupon_type, prices_hash|
        if device_model.prices.find_by_coupon_code(prices_hash[:coupon_code]).blank?
          device_model.prices.create( prices_hash)
        end
      end
    end

  end
end