class CreateVitals < ActiveRecord::Migration
  def self.up
    create_table :vitals do |t|
    end
  end

  def self.down
    drop_table :vitals
  end
end