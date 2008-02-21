class CreateFirmwareUpgrades < ActiveRecord::Migration
  def self.up
    create_table :firmware_upgrades do |t|
      t.column :id, :primary_key, :null => false
      t.column :ftp_id, :integer
      t.column :version, :string
      #t.timestamps
    end
  end

  def self.down
    drop_table :firmware_upgrades
  end
end
