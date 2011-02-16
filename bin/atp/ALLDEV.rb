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


#idev.each do |irow|
#    www.each do |wrow|
#      puts " #{irow[1]} " if irow[1].strip != wrow[1].strip 
#    end
#end

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
	puts zrow[0].strip + " " + zrow[1].strip + " " + zrow[2].strip + " " + zrow[3].strip + " " + zrow[4].strip + " " + zrow[5].strip
	end
 end
end



