class CreateGroups < ActiveRecord::Migration
  def self.up
    create_table :groups do |t|
      t.column :id,                 :primary_key, :null => false 
      t.column :name,               :string,      :null => false
      t.column :created_at,         :datetime
      t.column :updated_at,         :datetime
    end
    
  end

  def self.down
    drop_table :groups
  end
end
