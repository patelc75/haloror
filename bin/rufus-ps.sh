#!/bin/bash
#This script was modified by Chirag P. from a script found at this site: http://unix.stackexchange.com/questions/22892/how-do-use-awk-along-with-a-command-to-show-the-process-id-with-the-ps-command/22936#22936
ps -e -O start_time --sort start_time | grep ruby |
while read LINE; do 
  eval $(echo $LINE | awk '{pid=$1; date=$2; time=$5; task=$9; printf "echo -n \"%s %s %s \t\"; pwdx %s\n", date, time, task, pid}' ) 
done    