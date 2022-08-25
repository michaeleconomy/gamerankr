  $(document).ready(function() {
    if ($('#details').height() > 97) {
      $('#moreDetails').show();
      $('#details').addClass("shrunk");
    }

    $('#moreDetails').click(function() {
      $('#moreDetails').hide();
      $('#lessDetails').show();
      $('#details').removeClass("shrunk");
      return false;
    });

    $('#lessDetails').click(function() {
      $('#lessDetails').hide();
      $('#moreDetails').show();
      $('#details').addClass("shrunk");
      return false;
    });
  })