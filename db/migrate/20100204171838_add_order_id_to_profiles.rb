class AddOrderIdToProfiles < ActiveRecord::Migration
  def self.up
  	add_column :user_intakes,:order_id,:integer
  end

  def self.down
  	remove_column :user_intakes,:order_id
  end
end
