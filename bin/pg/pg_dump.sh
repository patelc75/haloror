FILENAME=$1
pg_dump -h localhost -p 5432 -U postgres -F c -b -v -f "$FILENAME`eval date +%Y%m%d`" haloror