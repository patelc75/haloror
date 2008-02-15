// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
Element.addMethods({
    toggleClassName: function(element, className) {
        if (!(element = $(element))) return;
        element.hasClassName(className) ?
            element.removeClassName(className) :
            element.className=className;
        return element;
    }
}); 

function toggleVTabs(current) {
    var node = document.getElementsByClassName("selsec");
    node[0].className = 'sec';
    current.className = 'selsec';
}

function toggleHTabs(current) {
    var node = document.getElementsByClassName("selectedTab");
    node[0].className = 'unselectedTab';
    current.className = 'selectedTab';
}

function updatePositions(li_id) {
	var num_ref = new Hash();
	num_ref[0] = 'th';
	num_ref[1] = 'st';
	num_ref[2] = 'nd';
	num_ref[3] = 'rd';
	num_ref[4] = 'th';
	num_ref[5] = 'th';
	num_ref[6] = 'th';
	num_ref[7] = 'th';
	num_ref[8] = 'th';
	num_ref[9] = 'th';
	
	obj = document.getElementById('call_list'); // get parent list
	CN = obj.childNodes; // get nodes
	x = 0;
	pos = 1;
	while(x < CN.length){ // loop through elements for the desired one
		if(document.getElementById(CN[x].id).className == 'active')
		{
			pos = pos+''
			var start = pos.length-1;
			var pos_end = num_ref[pos.substr(start,1)];
			
			document.getElementById(CN[x].id+'_position').innerHTML = pos+pos_end;
			pos++;
		}
		
		x++;
		
	}
}

var heartrate 	= "true";
var skin_temp 	= "true";

function overlay(w, val)
{
	if(val == false)
		val = "false";
	else
		val = "true";
		
	switch(w)
	{
		case 'heartrate':
			heartrate = val;
			break;
		case 'skin_temp':
			skin_temp = val;
			break;
	}
	
	SetCookie('heartrate', heartrate, 7);
	SetCookie('skin_temp', skin_temp, 7);
	
	//new Ajax.Request('/chart/update_overlay/', {method:'post', parameters:{'heartrate':heartrate,'skin_temp':skin_temp}});
}

function SetCookie(cookieName,cookieValue,nDays) {
 var today = new Date();
 var expire = new Date();
 if (nDays==null || nDays==0) nDays=1;
 expire.setTime(today.getTime() + 3600000*24*nDays);
 document.cookie = cookieName+"="+escape(cookieValue)
                 + ";expires="+expire.toGMTString();
}

function toggleContact(pos, id, status, what)
{
	if(document.getElementById('item_'+id+'_'+pos).className == 'active')
	{
		if(active[id] && isset(active[id][what]))
			status = active[id][what];
	
		if(!active[id])
			active[id] = [];
			
		if(status == 0)
			status = 1;
		else
			status = 0;
		
		active[id][what] = status;
	
	
		obj = document.getElementById('item_'+what+'_'+id);
	
		if(status)
			obj.src = '/images/call_list-'+what+'.png';
		else
			obj.src = '/images/call_list-'+what+'-inactive.png';
	}	
}

var active = [];
var caregiverActive = [];

function toggleCaregiver(action, pos, id, phone_active, email_active, text_active)
{
	if(!active[id])
		active[id] = [];
		
	if(!isset(active[id]['phone']))
		active[id]['phone'] = phone_active;
	if(!isset(active[id]['email']))
		active[id]['email'] = email_active;
	if(!isset(active[id]['text']))
		active[id]['text'] = text_active;
	
	
	if(action == 'disable')
	{
		
		document.getElementById('item_'+id+'_'+pos+'_position').innerHTML = '&nbsp;';
		document.getElementById('item_up_'+id).src = '/images/call_list-up-away.gif';
		document.getElementById('item_down_'+id).src = '/images/call_list-down-away.gif';
		document.getElementById('item_image_'+id).style.opacity = '.5';
		document.getElementById('item_firstname_'+id).style.color = 'gray';
		document.getElementById('item_lastname_'+id).style.color = 'gray';
		document.getElementById('item_active_'+id).src = '/images/call_list-active_disabled.gif';
		document.getElementById('item_away_'+id).src = '/images/call_list-away.gif';
		document.getElementById('item_phone_'+id).src = '/images/call_list-phone-inactive.gif';
		document.getElementById('item_email_'+id).src = '/images/call_list-email-inactive.gif';
		document.getElementById('item_text_'+id).src = '/images/call_list-text-inactive.gif';
		document.getElementById('item_trash_'+id).src = '/images/call_list-trash-inactive.gif';
		
		document.getElementById('item_edit_'+id).getElementsByTagName('a')[0].style.color = 'gray';

		callListImg[id] = '/images/call_list-item-away.gif';
	
		document.getElementById('item_'+id+'_'+pos).className = 'inactive';
	}
	else if(action == 'enable')
	{
		document.getElementById('item_up_'+id).src = '/images/call_list-up.gif';
		document.getElementById('item_down_'+id).src = '/images/call_list-down.gif';
		document.getElementById('item_image_'+id).style.opacity = '1';
		document.getElementById('item_firstname_'+id).style.color = '#4691b1';
		document.getElementById('item_lastname_'+id).style.color = '#4691b1';
		document.getElementById('item_active_'+id).src = '/images/call_list-active.gif';
		document.getElementById('item_away_'+id).src = '/images/call_list-away_disabled.gif';
		document.getElementById('item_trash_'+id).src = '/images/call_list-trash.gif';
	
		if(active[id]['phone'])
			document.getElementById('item_phone_'+id).src = '/images/call_list-phone.gif';
		
		if(active[id]['email'])
			document.getElementById('item_email_'+id).src = '/images/call_list-email.gif';
		
		if(active[id]['text'])
			document.getElementById('item_text_'+id).src = '/images/call_list-text.gif';
		
		document.getElementById('item_edit_'+id).getElementsByTagName('a')[0].style.color = '';

		callListImg[id] = '/images/call_list-item.gif';
	
		document.getElementById('item_'+id+'_'+pos).className = 'active';
	}
	
	updatePositions();
	swapCallListBg(pos, id);
}

var defaultCallListImg = '/images/call_list-item.gif';
var callListImg = [];

function swapCallListBg(pos, id, img)
{
	if(callListImg[id])
		img = callListImg[id];
	else if(img)
		img = img;
	else
		img = defaultCallListImg;
		
	document.getElementById('item_'+id+'_'+pos).style.background = "url('"+img+"') no-repeat";
}

function isset( variable )
{
	return( typeof( variable ) != 'undefined' );
}

/*
	moves an element in a drag and drop list one position up
*/

function moveElementUpforList(list, key) {
	var sequence=Sortable.sequence(list);
	var newsequence=[];
	var reordered=false;

	//move only, if there is more than one element in the list
	if (sequence.length>1) for (var j=0; j<sequence.length; j++) {

		//move, if not already first element, the element is not null
		if (j>0 && sequence[j].length>0 && sequence[j]==key) {
			var temp=newsequence[j-1];
			newsequence[j-1]=key;
			newsequence[j]=temp;
			reordered=true;
		}
		
		//if element not found, just copy array element
		else {
			newsequence[j]=sequence[j];
		}
	}

	if (reordered) Sortable.setSequence(list,newsequence);
	return reordered;
}

/*
moves an element in a drag and drop list one position down
*/

function moveElementDownforList(list, key) {
	var sequence=Sortable.sequence(list);
	var newsequence=[];
	var reordered=false;

	//move, if not already last element, the element is not null
	if (sequence.length>1) for (var j=0; j<sequence.length; j++) {
		//move, if not already first element, the element is not null
		if (j<(sequence.length-1) && sequence[j].length>0 && sequence[j]==key) {
			newsequence[j+1]=key;
			newsequence[j]=sequence[j+1];
			reordered=true;
			j++;
		}
		
		//if element not found, just copy array element
		else {
			newsequence[j]=sequence[j];
		}
	}

	if (reordered) Sortable.setSequence(list,newsequence);
	return reordered;
}

/*
handles moving up
*/

function moveElementUp(pos,id,call_order) {
	moveElementUpforList('call_list', pos);
	updatePositions();
	
	new Ajax.Request('/call_list/sort/', {asynchronous:true, evalScripts:true, parameters:serialize()})

	swapCallListBg(pos, id);
	toggleTooltip(id);
}

/*
handles moving down
*/

function moveElementDown(pos,id,call_order) {
	moveElementDownforList('call_list', pos);
	updatePositions();
	
	new Ajax.Request('/call_list/sort/', {asynchronous:true, evalScripts:true, parameters:serialize()})
	
	swapCallListBg(pos,id);
	toggleTooltip(id);
}

function serialize()
{
	var str;
	
	obj = document.getElementById('call_list'); // get parent list
	CN = obj.childNodes; // get nodes
	x = 0;
	pos = 1;
	while(x < CN.length){ // loop through elements
		var id = CN[x].id;
		var arr = new Array();
		arr = id.split('_');
		
		if(str)
			str += '&call_list[]='+arr[1];
		else
			str = 'call_list[]='+arr[1];
		
		x++;
		pos++;
	}
	
	return str;
}

var showTooltip = true;

function toggleTooltip(id)
{
	var e = document.getElementById('item_'+id+'_tooltip');
	
	if(e.style.display == 'none' && showTooltip)
		e.style.display = 'block';
	else
		e.style.display = 'none';
}

function disableTooltip(id)
{
	showTooltip = false;
	
	toggleTooltip(id);
}




var maxPosition = false;

function positionLabel(direction)
{
	var currentValue = parseInt($('position').value);
	
	if(maxPosition == false)
		maxPosition = currentValue;
		
	if(direction == 'increment')
	{
		if((currentValue+1)<=maxPosition)
		{
			value = currentValue+1;
			
		}
	}
	else if(direction == 'decrement')
	{
		if((currentValue-1)>0)
		value = currentValue-1;		
	}
	
	$('position').value = value;
	$('position_label').innerHTML = value;
}