class AddColumnsToOrders < ActiveRecord::Migration
  def self.up
    add_column :orders, :coupon_code_id,          :integer
    add_column :orders, :invoice_num,             :string
    add_column :orders, :payment_collector,       :string
    add_column :orders, :payment_type,            :string
    add_column :orders, :kit_owner,               :string
    add_column :orders, :kit_leased,              :boolean
    add_column :orders, :kit_charged_at,          :datetime
    add_column :orders, :kit_charged,             :decimal
    add_column :orders, :deposit_holder,          :string
    add_column :orders, :deposit_returned_at,     :datetime
    add_column :orders, :install_fee_amount,      :decimal
    add_column :orders, :install_fee_charged_at,  :date
    add_column :orders, :affiliate_fee_amount,    :decimal
    add_column :orders, :affiliate_fee_group_id,  :integer
    add_column :orders, :affiliate_fee_charged_at, :datetime
    add_column :orders, :referral_amount,         :decimal
    add_column :orders, :referral_group_id,       :integer
    add_column :orders, :referral_charged_at,     :datetime
  end

  def self.down
    # remove_column :orders, :coupon_code_id
    remove_column :orders, :invoice_num 
    remove_column :orders, :payment_collector 
    remove_column :orders, :payment_type 
    remove_column :orders, :kit_owner 
    # remove_column :orders, :kit_leased 
    remove_column :orders, :kit_charged_at 
    remove_column :orders, :kit_charged 
    remove_column :orders, :deposit_holder 
    remove_column :orders, :deposit_returned_at 
    remove_column :orders, :install_fee_amount 
    remove_column :orders, :install_fee_charged_at 
    remove_column :orders, :affiliate_fee_amount 
    remove_column :orders, :affiliate_fee_group_id 
    remove_column :orders, :affiliate_fee_charged_at
    remove_column :orders, :referral_amount 
    remove_column :orders, :referral_group_id 
    remove_column :orders, :referral_charged_at 
  end
end
