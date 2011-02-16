require 'rubygems'
require 'faster_csv'
require 'postgres'
  
conn = PGconn.connect("localhost", 5432, '', '', "atp", "postgres", "")  

idev=[]
FCSV.foreach("idevdevices.csv", :quote_char => '"', :col_sep =>'|', :row_sep =>"\n") do |row|
     b = row
     idev << b
end

www=[]
FCSV.foreach("livedevices.csv", :quote_char => '"', :col_sep =>'|', :row_sep =>"\n") do |row|
     c = row
	 www << c
end

i=[]
idev.each do |irow|
        j = irow[1].strip
	i << j
end

z=[]
www.each do |wrow|
	x = wrow[1].strip
	z << x
end

yy=[]
r = (i | z) - (i & z)
r.each do |rr|
	u = rr
	yy << u
end

idev.each do |zrow|
 yy.each do |yrow|
	if yrow == zrow[1].strip
	pain = zrow[6].strip
	if pain == ''
		thingie = "NULL"
	else
		thingie = zrow[6]
	end
	pain2 = zrow[5].strip
	if pain2 == ''
                thingie2 = "NULL"
        else
                thingie2 = zrow[5]
        end
	pain3 = zrow[4].strip
	if pain3 == ''
                thingie3 = "NULL"
        else
                thingie3 = zrow[4]
        end
	pain4 = zrow[3].strip
        if pain4 == ''
                thingie4 = "NULL"
        else
                thingie4 = zrow[3]
        end
	puts zrow[1]
	res = conn.exec("INSERT INTO devices (id,serial_number,active,mac_address,device_revision_id,work_order_id,pool_id) VALUES(#{zrow[0].strip},\'#{zrow[1].strip}\',FALSE,\'#{thingie4}\',#{thingie3},#{thingie2},#{thingie});")
	#print INSERT INTO devices (id,serial_number,active,mac_address,device_revision_id,work_order_id,pool_id) VALUES(#{zrow[0].strip},\'#{zrow[1].strip}\',FALSE,\'#{zrow[3].strip}\',\'#{zrow[4].strip}\',\'#{zrow[5].strip}\',#{thingie})
	puts zrow[1]
	end
 end
end



