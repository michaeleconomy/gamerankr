$(window).load(function(){
  var carousel = $(".carousel")
  setInterval(function(){
    var selected = carousel.children(':visible')
    selected.hide()
    var next_item = selected.next()
    if(next_item.length > 0) {
      next_item.show()
    }
    else {
      carousel.children().first().show()
    }
  }, 4000)
})
