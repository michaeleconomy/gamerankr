//TODO!!!!

function star_click(event){
  var e = Event.element(event)
  var ranking_num = e.readAttribute("ranking")
  persist_stars_click(e)
  $('ranking_ranking').value = ranking_num
}
function add_shelf_click(event){
  var e = Event.element(event)
  if(!e.match("a.addShelf")) {
    return false
  }
  var shelf_name = e.readAttribute("shelf_name")
  var shelf_id = e.readAttribute("shelf_id")
  
  var existing_shelf = $('shelf' + shelf_id)
  var removedShelfInputs = $('removeShelfInputs')
  
  if (existing_shelf) {
    var destroy = existing_shelf.down('.destroy')
    if (destroy) {
      if (destroy.value == "true") {
        destroy.value = "false"
        existing_shelf.show()
      }
      else {
        destroy.value = "true"
        existing_shelf.hide()
      }
    }
    else {
      existing_shelf.remove()
    }
    return false
  }
  
  var new_shelf_stuff = new Element('span', {id:'shelf'+shelf_id})
  new_shelf_stuff.insert(new Element('input',
    { type:'hidden',
      name:'ranking[ranking_shelves_attributes][' + (new Date().getTime()) + '][shelf_id]',
      value:shelf_id}))
  var shelf_link = e.clone()
  shelf_link.update(e.innerHTML)
  new_shelf_stuff.insert(shelf_link)
  $('added').insert(new_shelf_stuff)
  
  return false
}

$$(".stars a").each(function(a) {
  a.observe("click", star_click)
})

$$(".shelves").each(function(a) {
  a.observe("click", add_shelf_click)
})