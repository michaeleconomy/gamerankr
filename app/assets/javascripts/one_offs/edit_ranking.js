$(document).ready(function(){
  function star_click(event){
    var e = $(this)
    var ranking_num = e.attr("ranking")
    persist_stars_click(e)
    $('#ranking_ranking').val(ranking_num)
  }
  
  $(".shelves > div")
    .mouseover(function(){
      $(this).find('.chooseShelves').show()
    })
    .mouseout(function(){
      $(this).find('.chooseShelves').hide()
    })
    .children("a").click(function(){
      return false;
    })
    
  function add_shelf_click(event){
    var e = $(this)
    var shelf_name = e.data("shelf-name")
    var shelf_id = e.data("shelf-id")
  
    var existing_shelf = $('#shelf' + shelf_id)
    var removedShelfInputs = $('#removeShelfInputs')
  
    if (existing_shelf.length > 0) {
      var destroy = existing_shelf.find('.destroy')
      if (destroy.length > 0) {
        if (destroy.val() == "true") {
          destroy.val("false")
          existing_shelf.show()
        }
        else {
          destroy.val("true")
          existing_shelf.hide()
        }
      }
      else {
        existing_shelf.remove()
      }
      return false
    }
    var timestamp = new Date().getTime()
    var new_shelf_stuff = $("<span id='shelf" + shelf_id + "'>" +
      "<input type='hidden' " +
        "name='ranking[ranking_shelves_attributes][" + timestamp + "][shelf_id]' " +
        "value='" + shelf_id + "'/>" +      
      "</span>")
    var shelf_link = e.clone()
    new_shelf_stuff.append(shelf_link)
    $('#added').append(new_shelf_stuff)
  
    return false
  }
  
  $(".stars a").click(star_click)
  
  $(".addShelf").click(add_shelf_click)
})