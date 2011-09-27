class CreateBundle < ActiveRecord::Migration
  def self.up
    create_table :bundles do |t|
      t.column :id, :primary_key, :null => false
      t.column :timestamp, :datetime
      t.column :timestamp_server, :datetime
      t.column :device_id, :integer
      t.column :bundle_type, :string
    end
  end

  def self.down
    drop_table :bundles
  end
end