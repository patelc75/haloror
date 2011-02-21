/* change line 8 below for the function you want to see the source code for */
/* Usage: psql -f latest_vitals_trigger_function.sql -d haloror */

SELECT p.prosrc as "Source code"
FROM pg_catalog.pg_proc p
     LEFT JOIN pg_catalog.pg_namespace n ON n.oid = p.pronamespace
     LEFT JOIN pg_catalog.pg_language l ON l.oid = p.prolang
WHERE p.proname ~ '^(usage_minus_lost_data_gaps_and_battery_charge)$'
  AND pg_catalog.pg_function_is_visible(p.oid);