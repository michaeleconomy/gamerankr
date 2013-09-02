$(".truncatedMoreLink").click(function() {
  var e = $(this)
  e.prev().hide()
  e.hide()
  e.next().removeClass('hidden')
})