#Flex query to figure out chart loading problem from 1.6.14 push
curl -k -v --basic -u bettyallen:bettyallen -H "Content-Type: text/xml" -d "<ChartQuery><userID>41</userID><startdate>Fri May 27 20:15:03 2011 UTC</startdate><enddate>Fri May 27 20:15:03 2011 UTC</enddate><num_points>0</num_points></ChartQuery>" https://www.myhalomonitor.com/flex/chart

curl -k -v --basic -u bhydrick:bhydrick -H "Content-Type: text/xml" -d "<ChartQuery><userID>41</userID><startdate>Sun May 29 02:49:38 2011 UTC</startdate><enddate>Sun May 29 02:49:38 2011 UTC</enddate><num_points>0</num_points></ChartQuery>" https://sdev.myhalomonitor.com/flex/chart
       

#Panic
curl -v -k -H "Content-Type: text/xml" -d "<panic><device_id>1</device_id><duration_press>1000</duration_press><gw_timestamp>Mn Dec 25 15:52:55 -0600 2007</gw_timestamp><user_id>970</user_id><timestamp>Mon Dec 25 15:52:55 -0600 2007</timestamp></panic>" "https://sdev.myhalomonitor.com/panics?gateway_id=0&auth=9ad3cad0f0e130653ec377a47289eaf7f22f83edb81e406c7bd7919ea725e024" 


