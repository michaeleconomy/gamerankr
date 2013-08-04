$(document).ready(function(){
  $('input[data-default]').each(function() {
    var item = $(this)  
    if(item.val() == ""){
      item.val(item.data('default')).
        addClass("default").
        one("focus", function(){
          $(this).removeClass("default").val("")
        })
    }
  })
})