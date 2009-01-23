class AddAtpKeyToAtpItem < ActiveRecord::Migration
  def self.up
    add_column :atp_items, :atp_key, :string
  end

  def self.down
    remove_column :atp_items, :atp_key
  end
end
