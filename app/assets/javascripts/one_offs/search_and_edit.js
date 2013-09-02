$(document).ready(function(){
  $("#selectAll").click(function(){
    var checkboxes = $('input[type=checkbox]:visible')
    checkboxes.prop('checked', !checkboxes.is(':checked'))
    return false
  })
  
  $('#search_within').keyup(function(){
    var e = $(this)
    var search = e.val()
    $(".title").each(function(){
      var e = $(this)
      var item = e.closest(".listItem")
      if(search != "" && e.html().toLowerCase().indexOf(search) == -1){
        item.hide()
        item.find('input[type=checkbox]').prop('checked', false);
      }
      else {
        item.show()
      }
    })
  })
  
  var todo = null
  
  $(".edit_form").on("ajax:success", function(e, data, status, xhr){
    if(todo) {
      todo()
      todo = null
    }
  }).on("ajax:error", function(e, xhr, status, error){
    alert("error, please see console for details")
    console.log(e, xhr, status, error)
    todo = null
  })
  
  $('input[value=delete]').click(function(){
    todo = function(){
      $(':checked').closest(".listItem").remove()
    }
  })
  
  $('input[value="merge games"]').click(function(){
    todo = function() {
      var skip_first = true
      $(':checked').closest(".listItem").each(function() {
        if(skip_first){
          skip_first = false
          return
        }
        $(this).remove()
      })
    }
  })
})