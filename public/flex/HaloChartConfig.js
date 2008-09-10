function getConfig() {
    var config = new Object;
    
    //config.Version = "";  *Deprecated!*
	
    config.Debug = false;
    
    //make request to check to check if current user is admin
    try{
	    new Ajax.Request('/security/is_admin/', {
	        asynchronous: false,  
	        method: 'get',
	        onSuccess: function(transport) {
	            if(transport.responseText.match(/true/)){
	                config.Admin = true;
	            }
	            else{
	                config.Admin = false;
	            }
	        }
	    });
    }catch(err){
    	config.Admin = true;
    }
	
    config.ChartFile = -1; //change this value to 0 if you want to run file-based tests
    
    config.TimerInterval = 15;
	config.Timeout = 60;
	config.MinutesLive = 10; //minutes
	
	config.heartRateAxisMin = 0;
	config.heartRateAxisMax = 150;
	config.heartRateColor = "#E64F00";
    config.heartRateVarColor = "#BE8A6D";
    
	config.skinTempAxisMin = 70;
	config.skinTempAxisMax = 110;
	config.skinTempColor = "#E0C852";
	
	config.breathingAxisMin = 0;
	config.breathingAxisMax = 50;
	config.breathingColor = "#EF04FE";
    
    config.stepsColor = "#0491FE";
    
    config.activityColor = "#FE8504";
    
    /* set the URL based on the file test mode */
    if (config.ChartFile == -1) {
    
        var hostName;
        
    	if (window.location.hostname == "localhost"){
            hostName = "localhost:3000";
        }else{
            hostName = window.location.hostname;
        }

    	/* Get the URL from the current location: */
    	config.dataServiceURL = "http://" + hostName + "/flex/chart";
        
         /* NOTE:
    	 * The above line of code ONLY works in live server mode where the javascript file
    	 * is located on the server (obviously) because when you are debugging locally the 
    	 * window location is "file:///C:/somethingOrOther/myDebugDir" 
    	 * so, change this to point to one of the following in local debug sessions only!
    	 */
    	 
        if(config.dataServiceURL == "http:///flex/chart"){
	    	//config.dataServiceURL = "https://sdev.myhalomonitor.com/flex/chart";
	    	//config.dataServiceURL = "http://www.myhalomonitor.com/flex/chart";
	        config.dataServiceURL = "https://idev.myhalomonitor.com/flex/chart";
	        //config.dataServiceURL = "http://sdev.halomonitor.com/flex/chart";
	    }  
	      
    }else{
    	/* use a static file for testing... */
    	
    	//config.dataServiceURL = "data/results";
        config.dataServiceURL = "data/ChartData";
        //config.dataServiceURL = "data/ChartData_CrossUTCDate";
        //config.dataServiceURL = "data/OneSec_results";
    }
    
    if (config.Debug == true && config.Admin == true){
    	//alert(config.dataServiceURL);
    }
    
    return config;
                
}