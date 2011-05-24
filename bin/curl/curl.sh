#Acess Mode
curl -k -H "Content-Type: text/xml" -w %size_header% -d "<fall><device_id>5</device_id><gw_timestamp>Mon Dec 25 15:52:55 -0600 2007</gw_timestamp><magnitude>60</magnitude><severity>12</severity><timestamp>Mon Dec 25 15:52:55 -0600 2007</timestamp><user_id>5</user_id></fall>" "http://localhost:3000/falls?gateway_id=0&auth=9ad3cad0f0e130653ec377a47289eaf7f22f83edb81e406c7bd7919ea725e024"       

#Panic
curl -v -k -H "Content-Type: text/xml" -d "<panic><device_id>1</device_id><duration_press>1000</duration_press><gw_timestamp>Mn Dec 25 15:52:55 -0600 2007</gw_timestamp><user_id>939</user_id><timestamp>Mon Dec 25 15:52:55 -0600 2007</timestamp></panic>" "https://sdev.myhalomonitor.com/panics?gateway_id=0&auth=9ad3cad0f0e130653ec377a47289eaf7f22f83edb81e406c7bd7919ea725e024" 


