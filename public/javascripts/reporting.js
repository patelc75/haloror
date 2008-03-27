function toggle_user_hidden(user_id)
{
	var cur = $('user_'+user_id+'-hidden').style.display;
	
	if(cur == 'none')
	{
		$('user_'+user_id+'-hidden').style.display = 'block';
		$('user_'+user_id+'-toggle').innerHTML = '[-]';
	}		
	else
	{
		$('user_'+user_id+'-hidden').style.display = 'none';
		$('user_'+user_id+'-toggle').innerHTML = '[+]';
	}		
}