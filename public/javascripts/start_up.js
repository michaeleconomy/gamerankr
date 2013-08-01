function observe_selector(selector, options){
  var options_hash = $H(options)
  $$(selector).each(function(element){
    options_hash.each(function(events){
      element.observe(events.first(), events.last())
    })  
  })
}

var addShelves = $('#addShelves')
$(".addDiv").mouseover(add_div_mouseover)
  .mouseout(add_div_mouseout)
$(".stars a").mouseover(star_mouseover)
$(".stars").mouseout(star_mouseout)


$(".rank .stars a, .addDiv a, #addShelves a").click(add_ranking_click)

  // $("[tip_id]").each(function(elem) {
  //   var tip_id = elem.readAttribute("tip_id")
  //   if(!$(tip_id)) {
  //     alert('tip ' + tip_id + ' could not be found!')
  //     return
  //   }
  //   new Tooltip(elem.identify(), tip_id)
  // })
  
$(".truncatedMoreLink").click(truncated_more_link_click)


$(document).bind("facebook:loaded", function () {
  FB.Event.subscribe('comment.create', function(response) {
    
    var href = response.href
    FB.api("/comments", {ids:href}, function(response){
      var comments = response[href].data
      var last_comment = comments.last()
      var message = last_comment.message

      new Ajax.Request("/comments/notify", {
        method: 'post',
        parameters: {
                href: href,
                comment_id: response.commentID,
                parent_comment_id: response.parentCommentID,
                message: message,
              },
        onError: function() {
          alert("couldn't notify gameranker of comment!")
        }
      })
    })
  })
})


$.ajaxSetup({
  headers: {
    'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
  }
});