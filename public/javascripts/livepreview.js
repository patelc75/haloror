hookUpPreviewTo = function( item ) {
  repositionPreviewFor( item );
  $( item ).observe( 'mouseover', showPreview );
  $( item ).observe( 'mouseout', hidePreview );
}

repositionPreviewFor = function( item ) {
  var elementId = $(item).id;
  var elementPreviewId = elementId + '_preview';

  $(elementPreviewId).clonePosition( elementId, { setHeight: false, setWidth: false, offsetTop: 20 } );
}

showPreview = function( event ) {
  var elementPreviewId = Event.element(event).id + '_preview';

  $(elementPreviewId).show();
}

hidePreview = function( event ) {
  var elementPreviewId = Event.element(event).id + '_preview';

  $(elementPreviewId).hide();
}
