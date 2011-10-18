TIME_BACK_FROM_START=604800

#calculating the end date (current data starting at 8 AM central time)
DATESTR1=`date +%a\ %b\ %d`
DATESTR2="08:00:00 CST"
DATESTR3=`date +%Y`
ENDDATESTR="$DATESTR1 $DATESTR2 $DATESTR3"

#calculating the start date
UTCDATESTR=`date --date="$ENDDATESTR" +%s`
UTCDATESTR2=`expr $UTCDATESTR - $TIME_BACK_FROM_START`
STARTDATESTR=`date --date="@$UTCDATESTR2"`

FILE_START_NAME=`date --date="$STARTDATESTR" +%m-%d-%Y-8am`
FILE_END_NAME=`date --date="$ENDDATESTR" +%m-%d-%Y-8am`

TARGET_FILE="DataLossReport-$FILE_START_NAME-$FILE_END_NAME.txt"

#remove file if it already exists
if [ -f $TARGET_FILE ]; then
  rm $TARGET_FILE
fi

#collect data for all users
# my units
./data-loss-report.sh 13 $TIME_BACK_FROM_START $TARGET_FILE
./data-loss-report.sh 54 $TIME_BACK_FROM_START $TARGET_FILE
./data-loss-report.sh 60 $TIME_BACK_FROM_START $TARGET_FILE
./data-loss-report.sh 78 $TIME_BACK_FROM_START $TARGET_FILE

#CMO
./data-loss-report.sh 56 $TIME_BACK_FROM_START $TARGET_FILE

#Jeremy
./data-loss-report.sh 469 $TIME_BACK_FROM_START $TARGET_FILE

#May
./data-loss-report.sh 77 $TIME_BACK_FROM_START $TARGET_FILE

#Hugh
./data-loss-report.sh 452 $TIME_BACK_FROM_START $TARGET_FILE
./data-loss-report.sh 205 $TIME_BACK_FROM_START $TARGET_FILE

#Liz
./data-loss-report.sh 80 $TIME_BACK_FROM_START $TARGET_FILE

#Belt Clip NELB

./data-loss-report.sh 57 $TIME_BACK_FROM_START $TARGET_FILE
./data-loss-report.sh 109 $TIME_BACK_FROM_START $TARGET_FILE
./data-loss-report.sh 106 $TIME_BACK_FROM_START $TARGET_FILE

#Jerry
./data-loss-report.sh 84 $TIME_BACK_FROM_START $TARGET_FILE

#RESULTFILES=`ls *.txt | grep $FILE_END_NAME\.txt`
#tar -cvjf allresults_$FILE_END_NAME.tar.bz2 $RESULTFILES
