class CreateBatterAlertGroups < ActiveRecord::Migration
  def self.up
    AlertGroup.create :group_type => 'battery_outlet_status'
    AlertGroup.create :group_type => 'battery_level_status'
  end

  def self.down
  end
end
