$('#cst').bind("DOMSubtreeModified",function(){
var text = $('#cst').text();
  var img = go(text, 12, '', '', 40, 10, true, true);
				$('#cst').empty();
				$('#cst').append(img);
});
$('#ast').bind("DOMSubtreeModified",function(){
var text = $('#ast').text();
  var img = go(text, 12, '', '', 40, 10, true, true);
        $('#ast').empty();
        $('#ast').append(img);
});