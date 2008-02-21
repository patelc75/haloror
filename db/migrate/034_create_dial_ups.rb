class CreateDialUps < ActiveRecord::Migration
  def self.up
    create_table :dial_ups do |t|
      t.column :id, :primary_key, :null => false
      t.column :phone_number, :integer
      #t.timestamps
    end
  end

  def self.down
    drop_table :dial_ups
  end
end
