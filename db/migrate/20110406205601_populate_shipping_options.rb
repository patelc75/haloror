class PopulateShippingOptions < ActiveRecord::Migration
  def self.up 
    ShippingOption.create(:description => "UPS Overnight Shipping", :price => 60)
    ShippingOption.create(:description => "UPS 2 Day Shipping", :price => 28)
    ShippingOption.create(:description => "UPS Ground Shipping", :price => 16)        
  end

  def self.down
  end
end
