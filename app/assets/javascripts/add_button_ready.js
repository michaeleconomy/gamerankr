$(document).ready(function() {

  function add_ranking_click(event) {
    var e = $(this)
    var rank_div = e.closest(".rank")
    var loading = rank_div.find(".loading")
    loading.show()

    var shelf_id = e.attr("shelf_id")

    var add_div = rank_div.find(".addDiv")
    if (add_div.length > 0){
      add_div.remove()
      var shelves_div = $("<div class='shelves'>shelves: </div>")
      var shelf_name = e.attr("shelf_name")
      if (!shelf_name) {
        shelf_name = "played"
      }
      var shelf_link = $("<a href='#'>" + shelf_name + "</a>")
      if (shelf_id){
        shelf_link.href = "/shelves/" + shelf_id
      }
  		shelves_div.append(shelf_link)
      rank_div.append(shelves_div)
  	
      var edit_link = $("<a href='#' class='editLink'>edit my review</a>")
  		rank_div.append(edit_link)
    }

    var method
    var url = '/rankings'
    var ranking_num = e.attr("ranking")
    var parameters = {}
    if (shelf_id) {
      parameters["ranking[ranking_shelves_attributes][][shelf_id]"] = shelf_id
    }

    if (ranking_num){
      parameters["ranking[ranking]"] = ranking_num
      persist_stars_click(e)
    }

    var ranking_id = rank_div.attr("ranking_id")
    if(ranking_id) { //existing record
      method = 'put'
      url += "/" + ranking_id
    }
    else { //new record
      method = 'post'
      var port_id = rank_div.attr("port_id")
      parameters["ranking[port_id]"] = port_id
    }
    $.ajax(url, {
      type: method,
      data: parameters,
      dataType: "json",
      complete: function() {
       loading.hide()
      },
      statusCode: {
        401: function(transport) {
          window.location.href = '/auth/facebook'
        }
      },
      error: function(response, textStatus, errorThrown) {
        alert(textStatus + " " + errorThrown + " " + response)
        console.log(response, textStatus, errorThrown)
      },
      success: function(ranking) {
        var edit_link = rank_div.find('.editLink')
        edit_link.attr('href', "/rankings/" + ranking.id + "/edit")
        rank_div.attr("ranking_id", ranking.id)
        rank_div.find(".stars a").attr("shelf_id", null)
      }
    })
  }


  function add_div_mouseover(event){
    var e = $(this)
    if(!$.contains(e, addShelves)){
      e.append(addShelves)
    } 
    addShelves.show()
  }


  function add_div_mouseout(event){
    addShelves.hide()
  }

  function star_mouseover(event) {
    var t = $(this)
    t.parent().addClass("changing")
    t.addClass('selected')
    t.prevAll().addClass('selected')
    t.nextAll().removeClass('selected')
  }

  function star_mouseout(event) {
    var e = $(this)
    e.removeClass("changing")
    e.children().removeClass("selected")
  }

  addShelves = $('#addShelves')
  $(".addDiv").mouseover(add_div_mouseover)
    .mouseout(add_div_mouseout)
  $(".stars a").mouseover(star_mouseover)
  $(".stars").mouseout(star_mouseout)
  $(".rank .stars a, .addDiv a, #addShelves a").click(add_ranking_click)
})