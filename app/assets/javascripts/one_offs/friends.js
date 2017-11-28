$(document).ready(function(){
  var has_permission = null

  var saved_callback = null


  function ask_for_permission() {
    FB.login(function(response) {
      $('#permission_prompt').hide()
      $('#friends_not_on_gr').show()
      if (response.session) {
        if (response.perms.include("publish_stream")) {
          has_permission = true
          if(saved_callback) {
            saved_callback()
            saved_callback = null
          }
        } else {
          alert("you must grant permission before you can invite")
        }
      }
      else {
        alert("somehow you got signed out.... ")
      }
    }, {perms:'publish_stream'})
  
    return false
  }

  $("#permission_prompt").find("a").click(ask_for_permission)

  function check_for_permission(callback) {
    if(has_permission == null) {
      FB.api(
        {
          method: 'users.hasAppPermission',
          ext_perm: 'publish_stream'
        },
        function(response) {
          if(response == 1) {
            has_permission = true
          }
          else {
            has_permission = false
          }
          check_for_permission(callback)
        }
      )
      return
    }  
  
    if(has_permission) {
      callback()
    }
    else {
      saved_callback = callback
      $('#friends_not_on_gr').hide()
      var prompt = $('#permission_prompt')
      prompt.show()
    }
  }


  function send_invite(e){
    var uid = e.attr("uid")
    var friend_div = e.parent()
    e.remove()
    var loading = $("<div class='loading'></div>")
    friend_div.append(loading)
    FB.api('/' + uid + "/feed", 'post', {
      picture: 'TODO',
      link: 'http://www.gamerankr.com',
      name: 'GameRankr',
      description: 'Social video game reviews/rating site.'
    }, function(response){
      loading.remove()
      if(response.error) {
        friend_div.append(response.error.message)
        console.log(response)
      }
      else {
        friend_div.append("message sent")
      }
    })
  }

  function invite_onclick(event) {
    check_for_permission(function(){
      send_invite($(this))
    })
  
    return false
  }

  $('.friend a.button').click(invite_onclick)

  function search_changed(){
    var element = $(this);
    var search_string = element.value.toLowerCase()
    var selected_count = 0
    $('.friend .name').each(function(name){
      if(name.innerHTML.toLowerCase().include(search_string) && selected_count < 30){
        name.parent().show()
        selected_count++
      }
      else {
        name.parent().hide()
      }
    })
    var none_selected_div = $('none_selected')
    if(selected_count == 0) {
      none_selected_div.find('span').update(search_string)
      none_selected_div.show()
    }
    else {
      none_selected_div.hide()
    }
  };

  ["change", "keyup"].each(function(event){
    $('#friend_search').on(event, search_changed)
  })
})