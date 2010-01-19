class CreateDialUpLastSuccessfuls < ActiveRecord::Migration
  def self.up
    create_table :dial_up_last_successfuls do |t|
      t.column :id, :primary_key, :null => false
      t.integer :device_id

      t.string :last_successful_number

      t.string :last_successful_username

      t.string :last_successful_password


      t.timestamps

    end
  end

  def self.down
    drop_table :dial_up_last_successfuls
  end
end
