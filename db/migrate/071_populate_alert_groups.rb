class PopulateAlertGroups < ActiveRecord::Migration
  def self.up
    AlertGroup.create :group_type => 'info'
    AlertGroup.create :group_type => 'high'
    AlertGroup.create :group_type => 'critical'
    AlertGroup.create :group_type => 'battery'
    AlertGroup.create :group_type => 'connectivity'
  end

  def self.down
  end
end
