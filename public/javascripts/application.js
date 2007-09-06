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

function toggleTabs(current) {
    var node = document.getElementsByClassName("selsec");
    node[0].className = 'sec';
    current.className = 'selsec';
}