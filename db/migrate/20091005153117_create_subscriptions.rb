class CreateSubscriptions < ActiveRecord::Migration
  def self.up
    create_table :subscriptions do |t|
      t.column :id, :primary_key, :null => false 
      t.column :arb_subscriptionId, :integer
      t.column :user_id, :integer
      t.column :cc_last_four, :integer
      t.column :comments, :text

      t.timestamps
    end
  end

  def self.down
    drop_table :subscriptions
  end
end
