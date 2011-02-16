require 'rubygems'
require 'faster_csv'
require 'postgres'
  
conn = PGconn.connect("localhost", 5432, '', '', "atp", "postgres", "")  

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

#resprint = []
idev.each do |irow|
 www.each do |wrow|
   if irow[1].strip == wrow[1].strip
	res = conn.exec("UPDATE atp_item_results SET device_id = (\'#{wrow[0].strip}\') WHERE device_id = (\'#{irow[0].strip}\');")
	res = conn.exec("UPDATE atp_test_results SET device_id = (\'#{wrow[0].strip}\') WHERE device_id = (\'#{irow[0].strip}\');")
	res = conn.exec("UPDATE device_kits SET device_id = (\'#{wrow[0].strip}\') WHERE device_id = (\'#{irow[0].strip}\');")
	res = conn.exec("UPDATE gateway_passwords SET device_id = (\'#{wrow[0].strip}\') WHERE device_id = (\'#{irow[0].strip}\');")
        #res = ("UPDATE atp_item_results SET device_id = (\'#{wrow[0].strip}\') WHERE device_id = (\'#{irow[0].strip}\');")
	#resprint << res
   end
 end
end

#puts resprint
