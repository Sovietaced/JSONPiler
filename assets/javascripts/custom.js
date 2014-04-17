$('#cst').bind("DOMSubtreeModified",function(){
var text = $('#cst').text();
  var img = go(text, 12, '', '', 40, 10, true, true);
				$('#cst').empty();
				$('#cst').append(img);
});