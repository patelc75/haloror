#!/usr/bin/env bash

DATESTAMP=`date +%F-%R`
HOSTSTAMP=`uname -n`
HOMEDIR="/home/backup"
DUMPDIR="$HOMEDIR/dumps"
DUMPFILE="${HOSTSTAMP}-${DATESTAMP}"
SCHEMADUMPDIR="$DUMPDIR/schemas"
SCHEMADUMPFILE="SCHEMA-${HOSTSTAMP}-${DATESTAMP}"
ETCDIR="$HOMEDIR/etc"
DATABASE="haloror"
EXCLUDEFILE="$ETCDIR/exclude_tables.txt"
SCHEMAONLYFILE="$ETCDIR/exclude_tables.txt"
PGDUMP="/usr/bin/pg_dump"
EXCLUDEOPTIONS=""

if [ "$1" == "" ]; then
  TARGETHOST="backup@atl-web1.halomonitor.com"
else
  TARGETHOST="$1"
fi

TARGETDIR="dumps"
SCHEMATARGETDIR="$TARGETDIR/schemas"
TARGETLOADSCRIPT="tools/restore_from_master.sh"

function read_excludes {
  exec 3<&0
  exec 0<$EXCLUDEFILE
  while read line
  do
    EXCLUDEOPTIONS="$EXCLUDEOPTIONS -T $line"
  done
  exec 0<&3
}

function read_schemaonly {
  exec 3<&0
  exec 0<$SCHEMAONLYFILE
  while read line
  do
    SCHEMAONLYOPTIONS="$SCHEMAONLYOPTIONS --table $line"
  done
  exec 0<&3
}

#####################################
# BEGIN EXECUTION
#####################################

read_excludes
read_schemaonly
$PGDUMP -Fc $EXCLUDEOPTIONS $DATABASE > $DUMPDIR/$DUMPFILE.pgdump
$PGDUMP --schema-only $SCHEMAONLYOPTIONS $DATABASE > $SCHEMADUMPDIR/$SCHEMADUMPFILE.sql 
scp -q $DUMPDIR/$DUMPFILE.pgdump ${TARGETHOST}:${TARGETDIR}
scp -q $SCHEMADUMPDIR/$SCHEMADUMPFILE.sql ${TARGETHOST}:${SCHEMATARGETDIR}
ssh -q $TARGETHOST $TARGETLOADSCRIPT $DUMPFILE $SCHEMADUMPFILE '</dev/null >>~/dumplog 2>&1 &'


# Push tools out with:
# rsync -Ca etc tools backup@atl-web1.halomonitor.com:.
# from dfw-web3 assuming dfw-web3 is primary master and atl-web1 is cold slave
