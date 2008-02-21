class CreateDialUpsGateways < ActiveRecord::Migration
  def self.up
    create_table :dial_ups_gateways, :id => false do |t|
      t.column :gateway_id, :integer
      t.column :dial_up_id, :integer
      #t.timestamps
    end
  end

  def self.down
    drop_table :dial_ups_gateways
  end
end
