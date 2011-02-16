require 'rubygems'
require 'faster_csv'
  
idev=[]
FCSV.foreach("/home/web/haloror/bin/atp/atp-devices.csv", :quote_char => '"', :col_sep =>'|', :row_sep =>"\n") do |row|
     b = row
	 idev << b
end

www=[]
FCSV.foreach("/home/web/haloror/bin/atp/live-devices.csv", :quote_char => '"', :col_sep =>'|', :row_sep =>"\n") do |row|
     c = row
	 www << c
end

did_matches = []
idev.each do |irow|
 www.each do |wrow|
   if irow[1].strip == wrow[1].strip
	 did_row = []
	 did_row << irow[1].strip 
	 did_row << irow[0].strip
	 did_row << wrow[0].strip
	 did_matches << did_row
   end
 end
end

puts did_matches 
