FILENAME=$1
pg_restore -h localhost -p 5432 -U postgres -d haloror -v "$FILENAME"