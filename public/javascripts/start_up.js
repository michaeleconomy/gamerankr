Event.observe(window, "load", function() {
	addShelves = $('addShelves')
	
	$$(".addDiv").each(function(div) {
		div.observe("mouseover", add_div_mouseover)
		div.observe("mouseout", add_div_mouseout)
	})
	
  $$(".stars").each(function(div){
    div.observe("mouseover", star_mouseover)
    div.observe("mouseout", star_mouseout)
  })


	$$(".rank .stars a, .addDiv a, #addShelves a").each(function(a) {
    a.observe("click", add_ranking_click)
  })
  $$("[tip_id]").each(function(elem) {
	  var tip_id = elem.readAttribute("tip_id")
	  if(!$(tip_id)) {
		  alert('tip ' + tip_id + ' could not be found!')
		  return
		}
	  new Tooltip(elem.identify(), tip_id)
	})
	
	
	FB.Event.subscribe('comment.create', function(response) {
		
		href = response.href
		FB.api("/comments", {ids:href}, function(response){
			comments = response[href].data
			last_comment = comments.last()
			message = last_comment.message

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