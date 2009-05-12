#!/bin/sh
echo "recursively removing backup files from the app root directory"
pwd
find ./ -name '*~' -exec rm '{}' \; -print -or -name ".*~" -exec rm {} \; -print