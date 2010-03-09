class RmaTicket2626 < ActiveRecord::Migration
  def self.up
    add_column :rmas, :serial_number,   :string
    add_column :rmas, :related_rma,     :string
    add_column :rmas, :redmine_ticket,  :string
    add_column :rmas, :service_outage,  :string
    add_column :rmas, :ship_name,       :string
    add_column :rmas, :ship_city,       :string
    add_column :rmas, :ship_state,      :string
    add_column :rmas, :ship_zipcode,    :string
    add_column :rmas, :ship_address,    :text
    add_column :rmas, :notes,           :text
  end

  def self.down
    remove_columns :rmas, :notes, :zipcode, :state, :city, :address, :ship_name, :service_outage
    remove_columns :rmas, :redmine_ticket, :related_rma, :serial_number
  end
end

# existing columns
#
# created_at: 
# completed_on: 
# comments: 
# updated_at: 
# group_id: 
# created_by: 
# phone_number: 
# user_id: 
# status:
