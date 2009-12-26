class CreateUserIntakes < ActiveRecord::Migration
  def self.up
    create_table :user_intakes do |t|
      t.column :id, :primary_key, :null => false 
      t.column :installation_date, :date
      t.column :created_by,:integer
      t.column :updated_by, :integer

      t.timestamps

    end
  end

  def self.down
    drop_table :user_intakes
  end
end
