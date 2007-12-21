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
	obj = document.getElementById('call_list'); // get parent list
	CN = obj.childNodes; // get nodes
	x = 0;
	pos = 1;
	while(x < CN.length){ // loop through elements for the desired one
		if(document.getElementById(CN[x].id).className == 'active')
			document.getElementById(CN[x].id+'_position').innerHTML = pos;
		x++;
		pos++;
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

function move_li(list_id,li_id,dir,id){
  obj = document.getElementById(list_id); // get parent list
  CN = obj.childNodes; // get nodes
  x = 0;
  while(x < CN.length){ // loop through elements for the desired one
    if(CN[x].id == li_id){
      new_obj = CN[x].cloneNode(true); //create copy of node
      break; // End the loop since we found the element
    }else{
      x++;
      }
    }
  if(new_obj){
    if(dir == 'down'){ // Count up, as the higher the number, the lower on the page
      y = x + 1;
      while(y < CN.length){ // loop trhough elements from past the point of the desired element
        if(CN[y].tagName == 'LI'){ // check if node is the right kind
          old_obj = CN[y].cloneNode(true);
          break; // End the loop
        }else{
          y++;
          }
        }
      }
    if(dir == 'up'){ // Count down, as the lower the number, the higher on the page
      if(x > 0){
        y = x - 1;
        while(y >= 0){ // loop trhough elements from past the point of the desired element
          if(CN[y].tagName == 'LI'){ // check if node is the right kind
            old_obj = CN[y].cloneNode(true);
            break; // End the loop
          }else{
            y--;
            }
          }
        }
      }
    if(old_obj){ // if there is an object to replace, replace it.
      obj.replaceChild(new_obj,CN[y]);
      obj.replaceChild(old_obj,CN[x]);

	  new Ajax.Request('/call_list/sort/1/', {asynchronous:true, evalScripts:true, parameters:Sortable.serialize("call_list")})
	
	  //document.getElementById(li_id).style.backgroundImage = 'url(\'/images/call_list-item.gif\')';
	
	Sortable.create("call_list", {onUpdate:function(){new Ajax.Request('/call_list/sort/1/', {asynchronous:true, evalScripts:true, parameters:Sortable.serialize("call_list")})}, tag:'li'})
	updatePositions();

	swapCallListBg(id);
      }
    }
  }

function toggleContact(id, status, what)
{
	if(document.getElementById('item_'+id).className == 'active')
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

function toggleCaregiver(action, id, phone_active, email_active, text_active)
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
		document.getElementById('item_'+id+'_position').innerHTML = '&nbsp;';
		document.getElementById('item_up_'+id).src = '/images/call_list-up-away.png';
		document.getElementById('item_down_'+id).src = '/images/call_list-down-away.png';
		document.getElementById('item_image_'+id).style.opacity = '.5';
		document.getElementById('item_firstname_'+id).style.color = 'gray';
		document.getElementById('item_lastname_'+id).style.color = 'gray';
		document.getElementById('item_active_'+id).src = '/images/call_list-active_disabled.png';
		document.getElementById('item_away_'+id).src = '/images/call_list-away.png';
		document.getElementById('item_phone_'+id).src = '/images/call_list-phone-inactive.png';
		document.getElementById('item_email_'+id).src = '/images/call_list-email-inactive.png';
		document.getElementById('item_text_'+id).src = '/images/call_list-text-inactive.png';
		document.getElementById('item_edit_'+id).style.color = 'gray';

		callListImg[id] = '/images/call_list-item-away.gif';
	
		document.getElementById('item_'+id).className = 'inactive';
	}
	else if(action == 'enable')
	{
		document.getElementById('item_up_'+id).src = '/images/call_list-up.png';
		document.getElementById('item_down_'+id).src = '/images/call_list-down.png';
		document.getElementById('item_image_'+id).style.opacity = '1';
		document.getElementById('item_firstname_'+id).style.color = 'inherit';
		document.getElementById('item_lastname_'+id).style.color = 'inherit';
		document.getElementById('item_active_'+id).src = '/images/call_list-active.png';
		document.getElementById('item_away_'+id).src = '/images/call_list-away_disabled.png';
	
		if(active[id]['phone'])
			document.getElementById('item_phone_'+id).src = '/images/call_list-phone.png';
		
		if(active[id]['email'])
			document.getElementById('item_email_'+id).src = '/images/call_list-email.png';
		
		if(active[id]['text'])
			document.getElementById('item_text_'+id).src = '/images/call_list-text.png';
		
		document.getElementById('item_edit_'+id).style.color = 'inherit';

		callListImg[id] = '/images/call_list-item.gif';
	
		document.getElementById('item_'+id).className = 'active';
	
		updatePositions();
	}
	
	swapCallListBg(id);
}

var defaultCallListImg = '/images/call_list-item.gif';
var callListImg = [];

function swapCallListBg(id, img)
{
	if(callListImg[id])
		img = callListImg[id];
	else if(img)
		img = img;
	else
		img = defaultCallListImg;
		
	document.getElementById('item_'+id).style.background = "url('"+img+"') no-repeat";
}

function isset( variable )
{
return( typeof( variable ) != 'undefined' );
}