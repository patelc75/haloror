class Create911NameNumbers < ActiveRecord::Migration
  def self.up
    create_table :emergency_numbers, :force => true do |t|
      t.column :id, :primary_key, :null => false
      t.column :name, :string
      t.column :number, :string
      t.column :group_id, :integer
    end
    
    add_column :profiles, :emergency_number_id, :integer
  end

  def self.down
    remove_column :profiles, :emergency_number_id
    drop_table :emergency_numbers
  end
end
