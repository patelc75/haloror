class CreateSubscriptions < ActiveRecord::Migration
  def self.up
    create_table :subscriptions do |t|
      t.column :id, :primary_key, :null => false 
      t.column :arb_subscriptionId, :integer
      t.column :senior_user_id, :integer
      t.column :subscriber_user_id, :integer
      t.column :cc_last_four, :integer
      t.column :bill_amount, :decimal
      t.column :bill_to_first_name, :string
      t.column :bill_to_last_name, :string
      t.column :bill_start_date, :date
      t.column :special_notes, :text

      t.timestamps
    end
  end

  def self.down
    drop_table :subscriptions
  end
end
