$(document).ready(function(){function e(){return FB.login(function(e){$("#permission_prompt").hide(),$("#friends_not_on_gr").show(),e.session?e.perms.include("publish_stream")?(t=!0,s&&(s(),s=null)):alert("you must grant permission before you can invite"):alert("somehow you got signed out.... ")},{perms:"publish_stream"}),!1}function n(e){if(null==t)return void FB.api({method:"users.hasAppPermission",ext_perm:"publish_stream"},function(i){t=1==i,n(e)});if(t)e();else{s=e,$("#friends_not_on_gr").hide();$("#permission_prompt").show()}}function i(e){var n=e.attr("uid"),i=e.parent();e.remove();var o=$("<div class='loading'></div>");i.append(o),FB.api("/"+n+"/feed","post",{picture:"TODO",link:"http://www.gamerankr.com",name:"GameRankr",description:"Social video game reviews/rating site."},function(e){o.remove(),e.error?(i.append(e.error.message),console.log(e)):i.append("message sent")})}function o(){return n(function(){i($(this))}),!1}function r(){var e=$(this),n=e.value.toLowerCase(),i=0;$(".friend .name").each(function(e){e.innerHTML.toLowerCase().include(n)&&i<30?(e.parent().show(),i++):e.parent().hide()});var o=$("none_selected");0==i?(o.find("span").update(n),o.show()):o.hide()}var t=null,s=null;$("#permission_prompt").find("a").click(e),$(".friend a.button").click(o),["change","keyup"].each(function(e){$("#friend_search").on(e,r)})});