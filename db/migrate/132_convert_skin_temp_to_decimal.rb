class ConvertSkinTempToDecimal < ActiveRecord::Migration
  def self.up
    #Changes the column to a different type using the same parameters as add_column.
    #change_column(table_name, column_name, type, options)
    change_column :skin_temps, :skin_temp, :real, :null=> false
  end

  def self.down
    change_column :skin_temps, :skin_temp, :integer, :limit => 2, :null=> false
  end
end
