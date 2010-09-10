class AddColumnsToGroup < ActiveRecord::Migration
  def self.up
    add_column :groups, :charge_kit,      :string
    add_column :groups, :charge_mon,      :string
    add_column :groups, :charge_lease,    :string
    add_column :groups, :grace_mon_days,  :integer
    add_column :groups, :grace_mon_from,  :string
  end

  def self.down
    remove_columns :groups, :charge_kit, :charge_mon, :charge_lease, :grace_mon_days, :grace_mon_from
  end
end
