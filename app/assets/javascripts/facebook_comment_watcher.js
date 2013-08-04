$(document).bind("facebook:loaded", function () {
  FB.Event.subscribe('comment.create', function(response) {
    
    var href = response.href
    FB.api("/comments", {ids:href}, function(response){
      var comments = response[href].data
      var last_comment = comments.last()
      var message = last_comment.message
      
      
      $.ajax("/comments/notify", {
        type: 'post',
        data: {
                href: href,
                comment_id: response.commentID,
                parent_comment_id: response.parentCommentID,
                message: message,
              },
        error: function() {
          alert("couldn't notify gameranker of comment!")
        }
      })
    })
  })
})
