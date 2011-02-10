class InvoiceNote < ActiveRecord::Base
  belongs_to :invoice
  belongs_to :creator, :class_name => "User", :foreign_key => "created_by"
  belongs_to :updater, :class_name => "User", :foreign_key => "updated_by"
  
  # ============
  # = triggers =
  # ============
  
  def after_initialize
    self.user_id = self.invoice.user_id unless self.invoice.blank?
  end
end
