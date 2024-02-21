function persist_stars_click(e) {
  e.nextAll().removeClass("persisted")
  e.prevAll().addClass("persisted")
  e.addClass("persisted")
}

var addShelves;

$(document).ready(function() {

  function add_ranking_click(event) {
    var e = $(this)
    var rank_div = e.closest(".rank")
    var loading = rank_div.find(".loading")
    loading.show()

    var shelf_id = e.attr("shelf_id")
    rank_div.find(".stars a").attr("shelf_id", null)

    var add_div = rank_div.find(".addDiv")
    if (add_div.length > 0){
      addShelves.hide()
      $('#footer').append(addShelves) //move this so it doesn't lose it's click handler
      add_div.remove()
      
      var shelf_name = e.attr("shelf_name")
      if (!shelf_name) {
        shelf_name = "played"
      }
      rank_div.append(
        $("#componentsBox .editShelvesContainer").clone(true)
      )
  	
      var edit_link = $("<a href='#' class='editLink'>edit my review</a>")
  		rank_div.append(edit_link)
    }

    var parameters = {}
    if (shelf_id) {
      selected_shelf = rank_div.find("[shelf_id='" + shelf_id + "']")
      var existing_ranking_shelf_id = e.attr("ranking_shelf_id");
      if (existing_ranking_shelf_id) {
        if(rank_div.find("a[ranking_shelf_id]").length <= 1) {
          alert("can't remove the last shelf, to delete this rating " +
            "- click on edit, then click the delete link")
          loading.hide()
          return
        }
        selected_shelf.removeAttr("ranking_shelf_id")
        parameters["ranking[ranking_shelves_attributes][0][id]"] =
          existing_ranking_shelf_id
        parameters["ranking[ranking_shelves_attributes][0][_destroy]"] = "true"
      }
      else {
        selected_shelf.attr("ranking_shelf_id", "???")
        rank_div.find(".expander").after(selected_shelf)
        parameters["ranking[ranking_shelves_attributes][0][shelf_id]"] = shelf_id
      }
    }

    var ranking_num = e.attr("ranking")
    if (ranking_num){
      parameters["ranking[ranking]"] = ranking_num
      persist_stars_click(e)
    }

    var ranking_id = rank_div.attr("ranking_id")

    var url = '/rankings'
    var method
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
      error: function(response, textStatus, errorThrown) {
        alert(textStatus + " " + errorThrown + " " + response)
        console.log(response, textStatus, errorThrown)
      },
      success: function(ranking) {
        console.log(ranking)
        rank_div.find('.editLink').
          attr('href', "/rankings/" + ranking.id + "/edit")
        rank_div.attr("ranking_id", ranking.id)
        for(var i in ranking.ranking_shelves) {
          ranking_shelf = ranking.ranking_shelves[i]
          rank_div.find("a[shelf_id='" + ranking_shelf.shelf_id + "']").
            attr("ranking_shelf_id", ranking_shelf.id)
        }
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
  $(".rank .stars a, .addDiv a, #addShelves a, .editShelves a[shelf_id]").click(add_ranking_click)

  $(".editShelvesContainer").mouseover(
    function() {
      var t = $(this)
      t.find(".editShelves").addClass("expanded")
    }
  )

  $(".editShelvesContainer").mouseout(
    function() {
      var t = $(this)
      t.find(".editShelves").removeClass("expanded")
    }
  )
})