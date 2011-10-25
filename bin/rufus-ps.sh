#!/bin/bash
ps -e -O start_time --sort start_time | grep ruby |
while read LINE; do 
  eval $(echo $LINE | awk '{pid=$1; date=$2; time=$5; task=$9; printf "echo -n \"%s %s %s \t\"; pwdx %s\n", date, time, task, pid}' ) 
done    