class CallCenterResponseToEvents < ActiveRecord::Migration
  def self.up
  	add_column :events, :call_center_response, :datetime
  end

  def self.down
  	remove_column :events,:call_center_response
  end
end
