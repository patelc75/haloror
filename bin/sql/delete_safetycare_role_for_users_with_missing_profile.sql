/* refs #3775 75 users with missing profiles */
SELECT users.id, users.login, users.created_at 
FROM users 
LEFT OUTER JOIN profiles on profiles.user_id = users.id 
where profiles.user_id is null 
order by users.id desc;

/* find group_id for safety_care group */
select * from groups where name like '%safety%';

/* show users with missing profile that have halouser/safety_care role - be sure to update the authorizable_id with safety_care group_id! */
SELECT users.id as user_id, roles.id as role_id, roles.name, authorizable_type, authorizable_id 
from users, roles, roles_users 
where users.id = roles_users.user_id 
and roles_users.role_id = roles.id 
and roles.name = 'halouser'
and roles.authorizable_type = 'Group' 
and authorizable_id = 9
and users.id IN (SELECT users.id FROM users LEFT OUTER JOIN profiles on profiles.user_id = users.id WHERE profiles.user_id is null)
order by users.id desc; 

/* delete halouser/safety_care roles for users with missing profiles - be sure to update the role_id with the id resulted from previous query*/
DELETE from roles_users 
WHERE role_id = 83
AND user_id IN (SELECT users.id FROM users LEFT OUTER JOIN profiles on profiles.user_id = users.id WHERE profiles.user_id is null);
