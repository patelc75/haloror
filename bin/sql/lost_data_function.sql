/*this file can be opened in PgAdmin to test orientation_threshold_function */ 
select * from lost_data_function(1704, null, now(), '10 minutes');
select * from lost_datas where user_id = 1704;
delete from lost_datas;
