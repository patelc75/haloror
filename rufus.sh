#!/bin/bash
#copy this file to RAILS_ROOT and run it from there!
#MODE should be start or stop
MODE=$1

export RAILS_ENV=production 
./config/jobs/control.rb task $MODE &