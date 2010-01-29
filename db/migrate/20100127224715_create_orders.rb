class CreateOrders < ActiveRecord::Migration
  def self.up
    create_table :orders do |t|
      t.column :id,           :primary_key, :null => false 
  	  t.column :number,       :string
      t.column :bill_name,    :string
      t.column :bill_address, :text
      t.column :bill_city,    :string
      t.column :bill_state,   :string
      t.column :bill_zip,     :string
      t.column :bill_phone,   :string
      t.column :bill_email,   :string
      t.column :cost,         :float # order total value. currently same as product 'sold for a value of x'
      t.column :card_number,  :string
      t.column :card_expiry,  :date  # mass assignment has errors when string
      t.column :comments,     :text
      t.column :halouser,     :boolean

      t.column :ship_name,    :string
      t.column :ship_address, :text
      t.column :ship_city,    :string
      t.column :ship_state,   :string
      t.column :ship_zip,     :string
      t.column :ship_phone,   :string

      t.column :created_by,   :integer
      t.column :updated_by,   :integer
      t.timestamps
    end
  end

  def self.down
    drop_table :orders
  end
end
