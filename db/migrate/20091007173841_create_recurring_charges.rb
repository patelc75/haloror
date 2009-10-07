class CreateRecurringCharges < ActiveRecord::Migration
  def self.up
    create_table :recurring_charges do |t|
		 t.column :id, :primary_key, :null => false 
		 t.column :group_id, :integer
		 t.column :charge, :float
		 
      t.timestamps

    end
  end

  def self.down
    drop_table :recurring_charges
  end
end
