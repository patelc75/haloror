function toggle_user_hidden(user_id,page)
{
	var cur = $('user_'+user_id+'-hidden').style.display;
	
	if(cur == 'none')
	{
		$('user_'+user_id+'-hidden').style.display = 'block';
		new Ajax.Updater('user_'+user_id+'-hidden', 
										 '/reporting/user_hidden?user_id='+user_id+'&page='+page, 
										 {asynchronous:true, evalScripts:true});
		$('user_'+user_id+'-toggle').innerHTML = '[-]';
	}		
	else
	{
		$('user_'+user_id+'-hidden').style.display = 'none';
		$('user_'+user_id+'-toggle').innerHTML = '[+]';
	}		
}

function toggle_device_hidden(device_id)
{
	var cur = $('device_'+device_id+'-hidden').style.display;
	
	if(cur == 'none')
	{
		$('device_'+device_id+'-hidden').style.display = 'block';
		new Ajax.Updater('device_'+device_id+'-hidden', 
										 '/reporting/device_hidden?device_id='+device_id, 
										 {asynchronous:true, evalScripts:true});
		$('device_'+device_id+'-toggle').innerHTML = '[-]';
	}		
	else
	{
		$('device_'+device_id+'-hidden').style.display = 'none';
		$('device_'+device_id+'-toggle').innerHTML = '[+]';
	}		
}