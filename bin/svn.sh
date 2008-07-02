#!/bin/bash

USERNAME=$1
if ( test "$USERNAME" == "" ) then
  USERNAME='dakykilla'
fi

REVISION=$2 
if ( test "$REVISION" == "" ) then
  REVISION='HEAD'
fi

echo "$USER checking out revision $REVISION from http://svn2.assembla.com/svn/halotrac/trunk as svn user $USERNAME"
svn co -r $REVISION http://svn2.assembla.com/svn/halotrac/trunk/ --username $USERNAME haloror

