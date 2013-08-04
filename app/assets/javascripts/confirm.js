$(document).ready(function(){
  $("[data-confirm]").each(function() {
    var item = $(this)
    item.click(function(){
      return confirm(item.data("confirm"));
    })
  })
})