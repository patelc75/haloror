# 
#  Mon Jan 24 20:09:38 IST 2011, ramonrails
#   * https://redmine.corp.halomonitor.com/issues/4074
class RenameInvoicesColumns < ActiveRecord::Migration
  def self.up
    #   * does not remove any data type or content
    #   * documentation clip for postgresql implementation...
    # rename_column(table_name, column_name, new_column_name)
    # Renames a column in a table.
    #      # File activerecord/lib/active_record/connection_adapters/postgresql_adapter.rb, line 738
    # 738:       def rename_column(table_name, column_name, new_column_name)
    # 739:         execute "ALTER TABLE #{quote_table_name(table_name)} RENAME COLUMN #{quote_column_name(column_name)} TO #{quote_column_name(new_column_name)}"
    # 740:       end
    #   
    #   * data remained after db:migrate on localhost
    # >> Invoice.all.collect(&:referral_payout_at)
    #   Invoice Load (0.008463)   SELECT * FROM "invoices" 
    # => [nil, nil, nil, nil, nil, Tue, 18 Jan 2011 06:00:00 UTC 00:00]
    #
    rename_column :invoices, :affiliate_fee_charged_at, :affiliate_fee_payout_at
    rename_column :invoices, :referral_charged_at, :referral_payout_at
    #   * new column
    add_column :invoices, :install_fee_payout_date, :datetime
  end

  def self.down
  end
end
