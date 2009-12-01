require 'rubygems'
require 'faster_csv'
  

b=[]
FasterCSV.foreach("atp-devices.csv", :quote_char => '"', :col_sep =>'|', :row_sep =>"\n") do |row|
   a = row[0] + ', ' + row[1]
   b << a 
end

puts b
