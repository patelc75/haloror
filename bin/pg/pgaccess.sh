#!/bin/sh
#
# Provide Read Only Access On PostgreSQL Database
# Use: ./pgaccess $database $username
#

tables=$(psql $1 -A -t -c "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public';")

for table in $tables
do
echo "Providing select to $2 on $table"
psql $1 -c "GRANT SELECT ON $table to $2;"
done
