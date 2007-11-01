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

function updatePositions(current) {
	var divs = document.getElementById("call-list");
	for (var i=0;i<divs.length;i++){
	  alert(divs[i].style.left);
	} 
}

