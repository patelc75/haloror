class AddCrossStToProfiles < ActiveRecord::Migration
  def self.up
  	add_column :profiles,:cross_st,:string
  end

  def self.down
  	remove_column :profiles,:cross_st
  end
end
