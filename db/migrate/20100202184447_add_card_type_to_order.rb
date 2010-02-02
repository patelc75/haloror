class AddCardTypeToOrder < ActiveRecord::Migration
  def self.up
    add_column :orders, :card_type, :string
  end

  def self.down
    remove_column :orders, :card_type
  end
end
