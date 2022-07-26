$(document).ready(function() {
  $(".followButton").on("ajax:send", function(e, xhr, status, error) {
    var thisJ = $(this);
    var id = thisJ.data('id');
    thisJ.hide();
    $("#followLoading" + id).show();
    console.log("send: " + id);
  }).on("ajax:success", function(e, data, status, xhr){
    var thisJ = $(this);
    var id = thisJ.data('id');
    $("#unfollowButton" + id).show();
    $("#followLoading" + id).hide();
    console.log("success: " + id);
  }).on("ajax:error", function(e, xhr, status, error) {
    var thisJ = $(this);
    var id = thisJ.data('id');
    alert("an error was encountered: " + xhr.responseText);
    console.log(e, xhr, status, error);
    thisJ.show();
    $("#followLoading" + id).hide();
    console.log("error: " + id);
  })


  $(".unfollowButton").on("ajax:send", function(e, xhr, status, error) {
    var thisJ = $(this);
    var id = thisJ.data('id');
    thisJ.hide();
    $("#followLoading" + id).show();
  }).on("ajax:success", function(e, data, status, xhr){
    var thisJ = $(this);
    var id = thisJ.data('id');
    $("#followButton" + id).show();
    $("#followLoading" + id).hide();
  }).on("ajax:error", function(e, xhr, status, error) {
    var thisJ = $(this);
    var id = thisJ.data('id');
    alert("an error was encountered: " + xhr.responseText);
    console.log(e, xhr, status, error);
    thisJ.show();
    $("#followLoading" + id).hide();
  })
})