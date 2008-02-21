class CreateFtps < ActiveRecord::Migration
  def self.up
    create_table :ftps do |t|
      t.column :id, :primary_key, :null => false
      t.column :server_name, :string
      t.column :login, :string
      t.column :password, :string
      t.column :path, :string
      #t.timestamps
    end
  end

  def self.down
    drop_table :ftps
  end
end
