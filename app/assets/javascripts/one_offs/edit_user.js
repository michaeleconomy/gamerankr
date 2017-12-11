$(document).ready(function(){
  $(".primaryEmailRadio").change(function() {
    if($(this).prop("checked")) {
      $(".primaryEmailRadio").not(this).prop("checked", false)
    }
  })
})
