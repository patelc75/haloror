class CreateInvoiceNotes < ActiveRecord::Migration
  def self.up
    create_table :invoice_notes do |t|
      t.column :id,           :primary_key, :null => false
      t.column :invoice_id,   :integer
      t.column :description,  :text
      t.column :created_by,   :integer
      t.column :updated_by,   :integer
      t.column :user_id,      :integer

      t.timestamps
    end
  end

  def self.down
    drop_table :invoice_notes
  end
end
