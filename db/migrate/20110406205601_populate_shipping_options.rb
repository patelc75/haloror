class PopulateShippingOptions < ActiveRecord::Migration
  def self.up 
    ShippingOption.create(:description => "UPS Overnight", :price => 60)
    ShippingOption.create(:description => "UPS 2 Day", :price => 28)
    ShippingOption.create(:description => "UPS Ground", :price => 16)        
  end

  def self.down
  end
end
