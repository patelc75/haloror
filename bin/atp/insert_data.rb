require 'rubygems'
require 'faster_csv'
require 'postgres'
  
conn = PGconn.connect("localhost", 5432, '', '', "atpmerge", "postgres", "")

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
	 #did_row = []
	 #did_row << irow[1].strip 
	 #did_row << irow[0].strip
	 #did_row << wrow[0].strip
	 #did_matches << did_row
	res = conn.exec("INSERT into devices VALUES (wrow[0], wrow[1], irow[2], irow[3], wrow[4], irow[5], irow[6], irow[0];")
   end
 end
end

res = conn.exec("select * from devices order by id limit 10;")

res.each do |row|
	puts row
end

