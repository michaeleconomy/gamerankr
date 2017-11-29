$(document).ready(function(){
  $(".new_game_series").on("ajax:success", function(e, data, status, xhr){
    var input = $(this).find('#game_series_series_name')
    $(".seriesList").append(
      $("<div class='series'>" + input.val() + "</div>")
    )
    input.val("")
  }).on("ajax:error", function(e, xhr, status, error) {
    alert("an error was encountered")
  })
  
  
  $(".edit_game_series").on("ajax:success", function(e, data, status, xhr){
    $(this).parent().remove()
  }).on("ajax:error", function(e, xhr, status, error) {
    alert("an error was encountered")
    console.log(e, xhr, status, error)
  })
})