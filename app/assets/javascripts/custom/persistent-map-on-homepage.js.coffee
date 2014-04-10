show_or_hide_persistent_map = () ->
  if $('html.persistent-map-on-homepage-only-module').size() > 0
    if $('[data-controller=home]').size() > 0
      $('#persistent_map_container').show()
    else
      $('#persistent_map_container').hide()

# Document hooks ******************************************************************************************************

# Loaded by maps

window.Nembrot.show_or_hide_persistent_map = show_or_hide_persistent_map
