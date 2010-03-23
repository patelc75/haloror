class CreatePaymentGatewayResponses < ActiveRecord::Migration
  def self.up
    create_table :payment_gateway_responses do |t|
      t.column :id, :primary_key, :null => false
      t.column :action, :string
      t.column :order_id, :integer
      t.column :amount, :integer
      t.column :success, :boolean
      t.column :authorization, :string
      t.column :message, :string
      t.column :params, :text

      t.timestamps
    end
  end

  def self.down
    drop_table :payment_gateway_responses
  end
end
