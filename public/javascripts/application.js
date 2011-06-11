var addShelves = null

function default_text_area(id, value) {
	var text_area = $(id)
	if(!text_area) {
		alert("couldn't find text area to default")
		return
	}
	if(!text_area.value.blank()) {
    return
	}
	text_area.value = value
	text_area.addClassName('grey')
	
	var handler = function() {
	  text_area.value = ''
	  text_area.removeClassName('grey')
	  text_area.stopObserving("focus", handler)
  }
  text_area.observe("focus", handler)
}

function persist_stars_click(e) {
  e.nextSiblings().invoke("removeClassName", "persisted")
  e.previousSiblings().invoke("addClassName", "persisted")
  e.addClassName("persisted")
}



function add_ranking_click(event) {
  var e = Event.element(event)
  if(!e.match("a")) {
    return
  }
  var rank_div = e.up(".rank")
  var loading = rank_div.down(".loading")
  loading.show()
	
  var shelf_id = e.readAttribute("shelf_id")

  var add_div = rank_div.down(".addDiv")
  if (add_div){
    add_div.remove()
    var shelves_div = new Element("div", {"class":"shelves"})
    shelves_div.insert("shelves: ")
    var shelf_name = e.readAttribute("shelf_name")
    if (!shelf_name) {
      shelf_name = "played"
    }
    var shelf_link = new Element("a", {href:'#'})
    if (shelf_id){
      shelf_link.href = "/shelves/" + shelf_id
    }
    shelf_link.insert(shelf_name)
		shelves_div.insert(shelf_link)
    rank_div.insert(shelves_div)
		
    var edit_link = new Element("a", {href:'#'})
    edit_link.insert("edit my review")
    edit_link.addClassName("editLink")
		rank_div.insert(edit_link)
  }
	
  var method
  var url = '/rankings'
  var ranking_num = e.readAttribute("ranking")
  var parameters = {}
  if (shelf_id) {
    parameters["ranking[ranking_shelves_attributes][][shelf_id]"] = shelf_id
  }
  
  if (ranking_num){
    parameters["ranking[ranking]"] = ranking_num
    persist_stars_click(e)
  }
	

  var ranking_id = rank_div.readAttribute("ranking_id")
  if(ranking_id) { //existing record
    method = 'put'
    url += "/" + ranking_id
  }
  else { //new record
    method = 'post'
    var port_id = rank_div.readAttribute("port_id")
    parameters["ranking[port_id]"] = port_id
  }
  new Ajax.Request(url, {
    method: method,
    parameters: parameters,
    onComplete: function() {
     loading.hide()
    },
    on401: function(transport) {
      window.location.href = '/auth/facebook'
		},
    onFailure: function(transport) {
      alert(transport.responseText)
    },
    onSuccess: function(transport) {
      var ranking = transport.responseText.evalJSON()
      var edit_link = rank_div.down('.editLink')
      edit_link.href = "/rankings/" + ranking.ranking.id + "/edit"
      rank_div.writeAttribute("ranking_id", ranking.ranking.id)
      rank_div.select(".stars a").each(function(star) {
	      star.writeAttribute("shelf_id", null)
    	})
    }
  })
}


function add_div_mouseover(event){
  var e = Event.element(event)
  if(!e.match(".addDiv")){
    e = e.up(".addDiv")
  }
  if(!addShelves.descendantOf(e)){
    e.insert(addShelves)
  } 
  addShelves.show()
}


function add_div_mouseout(event){
  addShelves.hide()
}


function star_mouseover(event) {
  var e = Event.element(event)
  if(e.match('img')){
    return
  }
	
  if(e.hasClassName("stars")) {
    return
  }
  e.up().addClassName("changing")
  var prev = e
  while(prev) {
    prev.addClassName('selected')
    prev = prev.previous()
  }
}

function star_mouseout(event) {
  var e = Event.element(event)
  if(e.match('img')){
    return
  }
  if(!e.hasClassName("stars")) {
    e = e.up(".stars")
  }
  e.removeClassName("changing")
  e.childElements().invoke("removeClassName", "selected")
}