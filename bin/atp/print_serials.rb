require 'rubygems'
require 'faster_csv'
  


FasterCSV.foreach("atp-devices.csv", :quote_char => '"', :col_sep =>'|', :row_sep =>"\n") do |row|
   b = row[1]
   puts b
end

