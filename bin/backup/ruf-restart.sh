#!/bin/bash
#####################################::::Notes::::#####################################################
## Shell script to restart rufus jobs after they crash from PSQL restarting during the cold dumps    ##
## cold dumps happen at 2:30 AM CST for DEV and 3:30 AM CST for IDEV                                 ##
## **Note** Some rufus jobs will not function from 2:30 AM CST to 3:55 AM CST when this runs in cron ##
#######################################################################################################

# Start Script Note
echo " " 
date
echo "Starting Rufus Job Restart Cron"
ruby=/usr/local/bin/ruby

# Change To SDEV Project Root
cd /home/web/haloror

# Stop Rufus Jobs
#./rufus.sh stop bundlejob 
./rufus.sh stop task  
#./rufus.sh stop reporting 
./rufus.sh stop critical_alert 
#./rufus.sh stop safetycare 

# Sleep for 10 seconds to allow job to finish stopping
sleep 15

# Start Rufus Jobs
#./rufus.sh start safetycare 
#./rufus.sh start bundlejob 
./rufus.sh start task 
#./rufus.sh start reporting 
./rufus.sh start critical_alert 

# wait for logs to update
sleep 10

# End Script Note
echo "Ending Rufus Job Restart Cron"
date
echo " " 
