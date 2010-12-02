/* refs #3666 auto-increment safetycare account number */
select id, first_name, last_name, account_number from profiles where account_number is not null order by id desc;
update profiles set account_number = '' where account_number !='HM0010';

/* refs #3740 pull all gateways that are in ethernet mode */
select * from devices 
where id in (select device_id from access_mode_statuses where mode = 'ethernet') 
and  id in (select id from devices where serial_number like 'H2%');	

SELECT users.id as user_id, profiles.first_name, profiles.last_name, roles.id as role_id, roles.name, groups.name
from users, roles, roles_users, groups, profiles 
where users.id = roles_users.user_id 
and roles_users.role_id = roles.id 
and roles.name = 'halouser'
and roles.authorizable_type = 'Group' 
and roles.authorizable_id = groups.id
and groups.name = 'ems'
and users.id = profiles.user_id
order by users.id;  

curl -v -k -H "Content-Type: text/xml" -d "<panic><device_id>26</device_id><duration_press>1000</duration_press><gw_timestamp>Mon Dec 25 15:52:55 -0600 2007</gw_timestamp><user_id>682</user_id><timestamp>Mon Dec 25 15:52:55 -0600 2007</timestamp></panic>" "https://sdev.myhalomonitor.com/panics?gateway_id=0&auth=9ad3cad0f0e130653ec377a47289eaf7f22f83edb81e406c7bd7919ea725e024"

/* "Pg funciton users_by_role_and_group() to show all halousers for safety_care group for example" */
select * from users_by_role_and_group('halouser', 'ems');
drop function users_by_role_and_group();
drop type user_by_role_and_group;

