$(document).ready(function(){
  $("#selectAll").click(function(){
    var checkboxes = $('input[type=checkbox]')
    checkboxes.prop('checked', !checkboxes.is(':checked'))
    return false
  })
})