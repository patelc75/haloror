FILENAME=$1
pg_restore -h localhost -p 5432 -U postgres -d ldev -v "dfw-web1.halomonitor.com-04-30-2010(19:39:09CDT).sql"