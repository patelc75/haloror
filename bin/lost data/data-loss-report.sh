#  bash
#  detect data loss gaps on server
#  11/11/2010
#  CLS - Halo Monitoring
#

#USER_ID=78
USER_ID=$1
VITAL_MIN_GAP_SIZE=360
SKINTEMP_MIN_GAP_SIZE=360

#indicates the span being searched for data loss
# 1 day
#TIME_BACK_FROM_START=86400
TIME_BACK_FROM_START=$2

TARGET_FILE=$3

#30 days
#TIME_BACK_FROM_START=2592000

#checks if there's old results
OLD_RESULT_CHECK=`echo "select *,end_time-begin_time as duration from lost_datas where user_id = $USER_ID;" | psql ldev | grep rows`

#delete old results if there are any
if [ "$OLD_RESULT_CHECK" == "(0 rows)" ]; then
  echo "No old vitals results found!"
else
  TMP_OUTPUT=`echo "delete from lost_datas where user_id = $USER_ID;" | psql ldev`
  echo "Deleted old vitals results."
fi

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

#file to append
#TARGET_FILE="user_$USER_ID\_data_loss_$FILE_START_NAME\_$FILE_END_NAME.txt"

#get lost vitals data
TMP_OUTPUT=`echo "select * from lost_data_function( $USER_ID, '$STARTDATESTR', '$ENDDATESTR', '$VITAL_MIN_GAP_SIZE seconds');" | psql ldev`

#write header describing user data
echo "User Id: $USER_ID">> $TARGET_FILE
echo "Range  : $STARTDATESTR to $ENDDATESTR">> $TARGET_FILE
echo "">> $TARGET_FILE

#report lost vitals data
echo "Lost Vitals Data:"
echo "Lost Vitals Data:" >> $TARGET_FILE
#echo "select *,end_time-begin_time as duration from lost_datas where user_id = $USER_ID;" | psql ldev 2>&1 > user_$USER_ID\_vitals_loss_$FILE_START_NAME\_$FILE_END_NAME.txt
echo "select *,end_time-begin_time as duration from lost_datas where user_id = $USER_ID;" | psql ldev 2>&1 >> $TARGET_FILE
#cat user_$USER_ID\_vitals_loss_$FILE_START_NAME\_$FILE_END_NAME.txt

#checks if there's old skin temp results
OLD_RESULT_CHECK=`echo "select *,end_time-begin_time as duration from lost_data_skin_temps where user_id = $USER_ID;" | psql ldev | grep rows`

#delete old results if there are any
if [ "$OLD_RESULT_CHECK" == "(0 rows)" ]; then
  echo "No old skin temp results found!"
else
  TMP_OUTPUT=`echo "delete from lost_data_skin_temps where user_id = $USER_ID;" | psql ldev`
  echo "Deleted old skin temp results."
fi

#get lost skin temp data
TMP_OUTPUT=`echo "select * from lost_data_skin_temp_function( $USER_ID, '$STARTDATESTR', '$ENDDATESTR', '$SKINTEMP_MIN_GAP_SIZE seconds');" | psql ldev`

#report lost skin temp data
echo "Lost Skin Temp Data:"
echo "Lost Skin Temp Data:" >> $TARGET_FILE
#echo "select *,end_time-begin_time as duration from lost_data_skin_temps where user_id = $USER_ID;" | psql ldev 2>&1 > user_$USER_ID\_skin_temp_loss_$FILE_START_NAME\_$FILE_END_NAME.txt
echo "select *,end_time-begin_time as duration from lost_data_skin_temps where user_id = $USER_ID;" | psql ldev 2>&1 >> $TARGET_FILE
#cat user_$USER_ID\_skin_temp_loss_$FILE_START_NAME\_$FILE_END_NAME.txt
echo "">> $TARGET_FILE
echo "">> $TARGET_FILE
