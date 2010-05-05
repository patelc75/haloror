class AddPercentageToWeightScalesAndBloodPressures < ActiveRecord::Migration
  def self.up
  	add_column :weight_scales,:percentage, :integer, :limit => 1
  	add_column :blood_pressures,:percentage, :integer, :limit => 1
  end

  def self.down
  	remove_column :weight_scales,:percentage
  	remove_column :blood_pressures,:percentage
  end
end
