class UpdateCancelDateInInvoicesWhenUserCancelled < ActiveRecord::Migration
  def self.up
    # 
    #  Sun May 22 01:26:51 IST 2011, ramonrails
    #   * https://redmine.corp.halomonitor.com/issues/4486
    #   * Write migration to copy users.cancelled_at to corresponding invoices.cancelled_date only if invoices.cancelled_date is NULL
    User.cancelled.each do |_user|
      _user.invoice.update_attribute( cancelled_date, _user.cancelled_at) if _user.invoice.cancelled_date.blank? unless _user.invoice.blank?
    end
  end

  def self.down
  end
end
