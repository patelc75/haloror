class CreateRmaItems < ActiveRecord::Migration
  def self.up
    create_table :rma_items do |t|
      t.column  :id,                  :primary_key, :null => false 
      t.column  :original_serial,     :string
      t.column  :replacement_serial,  :string
      t.column  :shipped_serial,      :string
      t.column  :status,              :string
      t.column  :redmine_ticket,      :string
      t.column  :atp_status,          :string
      t.column  :shipped_on,          :date
      t.column  :reinstalled_on,      :date
      t.column  :completed_on,        :date
      t.column  :received_on,         :date
      t.column  :shipped_on,          :date
      t.column  :atp_on,              :date
      t.column  :repair_action,       :text
      t.column  :reason_for_return,   :text
      t.column  :condition_of_return, :text
      t.column  :notes,               :text
      t.column  :rma_id,              :integer
      t.column  :device_model_id,     :integer
      t.column  :user_id,             :integer
      t.column  :group_id,            :integer
      t.column  :created_at,          :datetime
      t.column  :updated_at,          :datetime
    end
  end

  def self.down
    drop_table :rma_items
  end
end
