FILENAME=$1
pg_dump -h localhost -p 5432 -U postgres -T battery_reminders -T battery_criticals -T battery_pluggeds -T battery_unpluggeds -T events -T vitals -T batteries -T skin_temps -T steps -T oscope_msgs -T mgmt_queries -T mgmt_cmds -T mgmt_responses -T halo_debug_msgs -T points -F c -b -v -f "$FILENAME`hostname`-`eval date +%m-%d-%Y`(`eval date +%H:%M:%S%Z`).sql" haloror