class CreateVitals < ActiveRecord::Migration
  def self.up
    create_table :vitals do |t|
	  t.column :id, :primary_key, :null => false 
    end
  end

  def self.down
    drop_table :vitals
  end
end