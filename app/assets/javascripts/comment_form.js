var foo = null;
$(document).ready(function() {
	$(".new_comment").on("ajax:success", function(e, data, status, xhr){
	  location.reload()
	}).on("ajax:error", function(e, xhr, status, error) {
	  alert("an error was encountered: " + xhr.responseText)
	  foo = xhr.responseText
    console.log(e, xhr, status, error)
	})
})