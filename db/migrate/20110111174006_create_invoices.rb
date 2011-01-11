class CreateInvoices < ActiveRecord::Migration
  def self.up
    # 
    #  Tue Jan 11 23:11:31 IST 2011, ramonrails
    #   * https://redmine.corp.halomonitor.com/issues/3988#note-10
    create_table :invoices do |t|
      t.column :id,           :primary_key, :null => false
      t.column :user_id, :integer
      t.column :coupon_code_id, :integer
      t.column :affiliate_fee_group_id, :integer
      t.column :referral_group_id, :integer
      t.column :invoice_num, :string
      t.column :payment_collector, :string
      t.column :payment_type, :string
      t.column :kit_owner, :string
      t.column :deposit_holder, :string
      t.column :kit_leased, :boolean
      t.column :kit_charged_at, :datetime
      t.column :deposit_returned_at, :datetime
      t.column :install_fee_charged_at, :datetime
      t.column :affiliate_fee_charged_at, :datetime
      t.column :referral_charged_at, :datetime
      t.column :kit_charged, :decimal
      t.column :install_fee_amount, :decimal
      t.column :affiliate_fee_amount, :decimal
      t.column :referral_amount, :decimal

      t.timestamps
    end
  end

  def self.down
    # drop_table :invoices # we do not need to reverse
  end
end
