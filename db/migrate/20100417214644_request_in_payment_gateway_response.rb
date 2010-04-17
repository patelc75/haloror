class RequestInPaymentGatewayResponse < ActiveRecord::Migration
  def self.up
    change_table :payment_gateway_responses do |t|
      t.column :request_data,     :text
      t.column :request_headers,  :text
    end
  end

  def self.down
    remove_columns :payment_gateway_responses, :request_data, :request_headers
  end
end
