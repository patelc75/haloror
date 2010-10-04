FILENAME=$1
pg_dump -h localhost -p 5432 -U postgres --schema-only -t battery_reminders -t battery_criticals -t battery_pluggeds -t battery_unpluggeds -t events -t vitals -t batteries -t skin_temps -t steps -t oscope_msgs -t mgmt_queries -t mgmt_cmds -t mgmt_responses -t halo_debug_msgs -t points -F c -b -v -f "$FILENAME-`eval date +%Y-%m-%d`.sql" haloror
