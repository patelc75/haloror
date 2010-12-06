/* refs #3666 auto-increment safetycare account number */
select id, first_name, last_name, account_number from profiles where account_number is not null order by id desc;
update profiles set account_number = '' where account_number !='HM0010';

/* refs #3740 pull all gateways that are in ethernet mode */
select * from devices 
where id in (select device_id from access_mode_statuses where mode = 'ethernet') 
and  id in (select id from devices where serial_number like 'H2%');	

curl -v -k -H "Content-Type: text/xml" -d "<panic><device_id>26</device_id><duration_press>1000</duration_press><gw_timestamp>Mon Dec 25 15:52:55 -0600 2007</gw_timestamp><user_id>827</user_id><timestamp>Mon Dec 25 15:52:55 -0600 2007</timestamp></panic>" "https://sdev.myhalomonitor.com/panics?gateway_id=0&auth=9ad3cad0f0e130653ec377a47289eaf7f22f83edb81e406c7bd7919ea725e024"

drop function users_by_role_and_group(text, text);
drop function users_by_group(text);
drop function users_by_role(text);

drop type user_by_role_and_group;
    	
select * from users_by_group('meridian') where demo_mode = false;
select * from users_by_role_and_group('halouser', 'meridian');
select * from users_by_role('halouser');


select user_id, first_name, last_name, group_name, status, test_mode, demo_mode, vip from users_by_role('halouser');

select count(*) from users where id in (select user_id from users_by_role('halouser') where status = 'Installed'); /* Installed Halousers*/
select count(*) from users where status = 'Installed';
select count(*) from users where id in (select user_id from users_by_role('halouser') where demo_mode = true); /* Demo Halousers*/
select count(*) from users where id in (select user_id from users_by_role('halouser')); /*Total Halousers */
 

select* from users_by_role('halouser');
select user_id from users_by_role('halouser') order by user_id;


	  create type role_row AS (
        role_id integer,   
  	    role text,
  	    group_or_user text
    	); 


  	CREATE OR REPLACE FUNCTION roles_by_user_id(integer)
  	RETURNS setof role_row
  	AS
  	$$
    SELECT roles.id as role_id, roles.name, groups.name
      from users, roles, roles_users, groups, profiles 
      where users.id = roles_users.user_id 
      and roles_users.role_id = roles.id 
      and roles.authorizable_type = 'Group' 
      and roles.authorizable_id = groups.id
      and users.id = profiles.user_id
      and users.id = $1
      order by roles.name;   
  	$$ 
  	LANGUAGE 'sql' STABLE;    



  	select * from roles_by_user_id(1);
  	drop function roles_by_user_id(integer);
drop type role_row;

  	select roles_users.*, roles.name from roles_users, roles where roles_users.role_id = roles.id and user_id = 19;
  	delete from roles_users where 