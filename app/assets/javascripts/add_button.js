function persist_stars_click(e) {
  e.nextAll().removeClass("persisted")
  e.prevAll().addClass("persisted")
  e.addClass("persisted")
}

var addShelves;