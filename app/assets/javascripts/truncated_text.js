$(document).ready(function() {
  $(".truncatedMoreLink").click(function() {
    var e = $(this)
    e.previous().hide()
    e.hide()
    e.next().removeClass('hidden')
  })
})