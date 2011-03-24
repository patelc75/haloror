#!/usr/bin/env bash

PGDIR="/usr/bin"
DATABASE="haloror"
DATESTAMP=`date +%F-%R`
HOSTSTAMP=`uname -n`
OLDDB="backup`date +%Y%m%d%H%M`"
RESTOREDB="restore`date +%Y%m%d%H%M`"
#OLDDB="${HOSTSTAMP}-${DATESTAMP}"
PGDUMP="/usr/bin/pg_dump"
HOMEDIR="/home/backup"
DUMPDIR="$HOMEDIR/dumps"
SCHEMADUMPDIR="$DUMPDIR/schemas"

if [ "$1" == "" ]; then
  echo "must specify a dumpfile to restore"
  exit 1
else
  RESTORENAME="$1"
  RESTOREFILE="${DUMPDIR}/${RESTORENAME}.pgdump"
  SCHEMARESTORENAME="$2"
  SCHEMARESTOREFILE="$SCHEMADUMPDIR/${SCHEMARESTORENAME}.sql"
  if [ ! -f $RESTOREFILE ]; then
    echo "$RESTOREFILE does not exist"
    exit 2
  elif [ ! -r $RESTOREFILE ]; then
    echo "$RESTOREFILE cannot be read"
    exit 3
  fi
fi

echo "Starting restore_from_master $1 at `date`"
echo "Creating $RESTOREDB and restoring from $RESTOREFILE"
$PGDIR/createdb -T template0 $RESTOREDB
$PGDIR/pg_restore -d $RESTOREDB $RESTOREFILE
echo "Renaming $DATABASE to $OLDDB and $RESTOREDB to $DATABASE"
(cd / && sudo -H -u postgres $PGDIR/pg_ctl -D /var/lib/pgsql/data -w -t 6000 -m fast restart)
$PGDIR/psql -e -d postgres -c "ALTER DATABASE $DATABASE RENAME TO $OLDDB; ALTER DATABASE $RESTOREDB RENAME TO $DATABASE"
echo "Dumping $OLDDB to $DUMPDIR/$HOSTSTAMP-$DATESTAMP.pgdump"
$PGDIR/pg_dump -Fc $OLDDB > $DUMPDIR/$HOSTSTAMP-$DATESTAMP.pgdump
echo "Dropping $OLDDB"
$PGDIR/dropdb $OLDDB
echo "Importing schemas for tables that are in $SCHEMARESTOREFILE"
$PGDIR/psql -U postgres $DATABASE < $SCHEMARESTOREFILE
echo "Done importing from $SCHEMARESTOREFILE"
echo "Done with restore_from_master $1 at `date`"
sudo -H -u web /home/web/ruf-restart.sh

# This requires two things in /etc/sudoers (with visudo):
# First, Defaults    requiretty MUST BE COMMENTED OUT
# second, add:
# backup  ALL=(postgres) NOPASSWD: /usr/bin/pg_ctl
# to the very end
