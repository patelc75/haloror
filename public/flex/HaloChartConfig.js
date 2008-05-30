function getConfig() {
    var config = new Object;
    
    config.Version = "1.4.5";
	
    config.Debug = true;
	
	// is current_user an admin?
	config.Admin = true;

    config.ChartFile = -1;
    
    config.TimerInterval = 15;
	config.Timeout = 60;
    
    if (config.ChartFile == -1) {
    
    	if (window.location.hostname == "localhost")
            hostName = "localhost:3000";
        else
            hostName = window.location.hostname;
         
         /* Get the URL from the current location: */
    	config.dataServiceURL = "http://" + hostName + "/flex/chart";
        
         /* NOTE:
    	 * The above line of code ONLY works in live server mode where the javascript file
    	 * is located on the server (obviously) because when you are debugging locally the 
    	 * window location is "file:///C:/somethingOrOther/myDebugDir" 
    	 * so, change this to point to one of the following in local debug sessions only!
    	 */
    	 
        if(config.dataServiceURL == "http:///flex/chart"){
	    	config.dataServiceURL = "http://www.myhalomonitor.com/flex/chart";
	        //config.dataServiceURL = "http://idev.myhalomonitor.com/flex/chart";
	        //config.dataServiceURL = "http://sdev.halomonitor.com/flex/chart";
	    }  
	      
    }else{
    	/* use a static file for testing... */
    	
        config.dataServiceURL = "data/ChartData";
        //config.dataServiceURL = "data/ChartData_CrossUTCDate";
    }
    
    if (config.Debug == true && config.Admin == true){
    	alert(config.dataServiceURL);
    }
    
    return config;             
}