var foo = null;
$(document).ready(function() {
	$(".new_comment").on("ajax:success", function(e, data, status, xhr){
	  location.reload()
	}).on("ajax:error", function(e, xhr, status, error) {
	  alert("an error was encountered: " + xhr.responseText)
    console.log(e, xhr, status, error)
	})

  more_link = $('.moreLink')
  more_link.on("ajax:success", function(e, data, status, xhr){
    response = xhr.responseJSON
    comments = response.comments
    comments_list = $(".commentsList")
    for(var i in comments) {
      comment = comments[i]
      user = comment.user
      comments_list.prepend(
        $("<div class='commentUser'>").append(
          $("<a class='userPhoto'>").
            attr("href", user.url).append(
            $("<img src='" + user.photo_url +"'>"))

        ).append(
          $("<div class='commentText'>").append(
            $("<a href='" + user.url + "'>" + user.real_name + "</a>")
          ).append(
            " \"" + comment.comment + "\""
          )
        ).append(
          $("<span class='lightGrey'>" + comment.date + "</span>")
        ).append(
          " "
        ).append(
          comment.mine ?
            $("<a href='" + comment.url + "' confirm='Are you sure?' + data-method='delete'>delete</a>") : null
        )
      )
    }
    if(response.next_page_url) {
      more_link.attr("href", response.next_page_url)
    }
    else {
      more_link.remove()
    }
  }).on("ajax:error", function(e, xhr, status, error) {
    alert("an error was encountered: " + xhr.responseText)
    foo = xhr.responseText
    console.log(e, xhr, status, error)
  })
})