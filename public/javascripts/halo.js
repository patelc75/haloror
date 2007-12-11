var heartrate 	= true;
var activity 	= true;
var skin_temp 	= true;

function overlay(w, val)
{
	switch(w)
	{
		case 'heartrate':
			heartrate = val;
			break;
		case 'activity':
			activity = val;
			break;
		case 'skin_temp':
			skin_temp = val;
			break;
	}
	
	SetCookie('heartrate', heartrate, 7);
	SetCookie('activity', activity, 7);
	SetCookie('skin_temp', skin_temp, 7);
	
	//new Ajax.Request('/chart/update_overlay/', {method:'post', parameters:{'heartrate':heartrate,'activity':activity,'skin_temp':skin_temp}});
}

function SetCookie(cookieName,cookieValue,nDays) {
 var today = new Date();
 var expire = new Date();
 if (nDays==null || nDays==0) nDays=1;
 expire.setTime(today.getTime() + 3600000*24*nDays);
 document.cookie = cookieName+"="+escape(cookieValue)
                 + ";expires="+expire.toGMTString();
}

function move_li(list_id,li_id,dir){
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
	
	  document.getElementById(li_id).style.backgroundImage = 'url(\'/images/call_list-item_bg.gif\')';
	
	Sortable.create("call_list", {onUpdate:function(){new Ajax.Request('/call_list/sort/1/', {asynchronous:true, evalScripts:true, parameters:Sortable.serialize("call_list")})}, tag:'li'})
      }
    }
  }