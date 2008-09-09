#/bin/bash
# this will generate httperf test for the vitals post
# update to reference ticket #406
echo "Enter: Server FQDN [example: sdev.halomonitor.com]"
read server_name
echo "Enter: Number of sessions [example: 100]"
read number_of_sessions
echo "Enter: Number of sessions per second [example: 20]"
read number_of_sessions_per_second
echo "httperf --ssl --server $server_name --add-header=\"content-type: text/xml\n\" --wsesslog $number_of_sessions,2,httperf-vitalspost --rate $number_of_sessions_per_second"
/usr/bin/httperf --server $server_name --add-header="content-type: text/xml\n" --wsesslog $number_of_sessions,2,httperf-vitalspost --rate $number_of_sessions_per_second
