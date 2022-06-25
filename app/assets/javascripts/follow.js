$(document).ready(function() {
  $("#follow_button").on("ajax:send", function(e, xhr, status, error) {
    $("#follow_button").hide();
    $("#follow_loading").show();
  }).on("ajax:success", function(e, data, status, xhr){
    $("#unfollow_button").show();
    $("#follow_loading").hide();
  }).on("ajax:error", function(e, xhr, status, error) {
    alert("an error was encountered: " + xhr.responseText)
    console.log(e, xhr, status, error)
    $("#follow_button").show();
  })


  $("#unfollow_button").on("ajax:send", function(e, xhr, status, error) {
    $("#unfollow_button").hide();
    $("#follow_loading").show();
  }).on("ajax:success", function(e, data, status, xhr){
    $("#follow_button").show();
    $("#follow_loading").hide();
  }).on("ajax:error", function(e, xhr, status, error) {
    alert("an error was encountered: " + xhr.responseText)
    console.log(e, xhr, status, error)
    $("#unfollow_button").show();
  })
})