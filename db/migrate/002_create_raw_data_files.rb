class CreateRawDataFiles < ActiveRecord::Migration
  def self.up
    create_table :raw_data_files do |t|
	  t.column :filename,     :string
      t.column :content_type, :string
      t.column :size,         :integer
      t.column :parent_id,    :integer
	  t.column :created_at,   :datetime
    end
  end

  def self.down
    drop_table :raw_data_files
  end
end
