class CreateProfiles < ActiveRecord::Migration
  def self.up
    create_table :profiles do |t|	
	  t.column :id, :primary_key, :null => false
	  t.column :user_id, :integer
	  t.column :first_name, :string
	  t.column :last_name, :string
	  t.column :address, :string
	  t.column :city, :string
	  t.column :state, :string
	  t.column :home_phone, :string
      t.column :work_phone, :string
	  t.column :cell_phone, :string
	  t.column :relationship, :string
	  t.column :email, :string
    end
  end

  def self.down
    drop_table :profiles
  end
end
