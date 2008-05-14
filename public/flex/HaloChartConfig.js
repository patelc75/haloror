function getConfig() {
    var config;
    var config = new Object;
    
    config.Version = "1.4";

    config.Debug = true;

    config.ChartFile = -1;
    
    if (config.ChartFile == -1) {
        config.dataServiceURL = "http://sdev.halomonitor.com/flex/chart";
        //config.dataServiceURL = "http://idev.myhalomonitor.com/flex/chart";
    }else{
        config.dataServiceURL = "data/ChartData";
    }
    
    return config;
                
}