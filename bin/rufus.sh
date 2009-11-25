#!/bin/bash
#copy this file to RAILS_ROOT and run it from there!
#MODE should be start or stop
MODE=$1
shift

TASKS=${@:-task safetycare bundlejob reporting critical_alert}

RAILS_ENV=${RAILS_ENV:-production}
export RAILS_ENV
for task in $TASKS; do
  ./config/jobs/control.rb $task $MODE &
done
