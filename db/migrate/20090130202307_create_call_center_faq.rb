class CreateCallCenterFaq < ActiveRecord::Migration
  def self.up
    create_table :call_center_faqs, :force => true do |t|
      t.column :id, :primary, :null => false
      t.column :faq_text, :text
      t.column :updated_by, :integer
      t.timestamps
    end
  end

  def self.down
    drop_table :call_center_faqs
  end
end
