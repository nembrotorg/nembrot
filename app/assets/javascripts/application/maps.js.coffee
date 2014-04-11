# SEE: 
#  https://github.com/kangaroo5383/google-maps-utility-library-v3/blob/master/richmarker/examples/richmarker.html
#  https://github.com/apneadiving/Google-Maps-for-Rails/wiki/Change-handler-behavior

class RichMarkerBuilder extends Gmaps.Google.Builders.Marker
  create_marker: ->
    options = _.extend @marker_options(), @rich_marker_options()
    @serviceObject = new RichMarker options

  rich_marker_options: ->
    marker = document.createElement('div')
    marker.setAttribute 'class', 'marker'
    marker.innerHTML = @args.marker
    _.extend @marker_options(), { content: marker, flat: true, anchor: RichMarkerPosition.TOP_LEFT }

load_maps = (theme) ->
  # If the theme uses a persistent map then populate the map (if necessary) then center on MAP_THIS_MARKER
  #  otherwise, simply show MAP_THIS_MARKER if available

  map_container = $('figure.map_container:visible .map')
  map_container_id = map_container.attr('id')

  if typeof map_container_id isnt 'undefined'
    if map_container_id is 'persistent_map'
      if typeof window.Nembrot.MAP_ALL_MARKERS isnt 'undefined' and !map_container.hasClass('rendered')
        render_map(map_container_id, window.Nembrot.MAP_ALL_MARKERS, theme, true)

      if typeof window.Nembrot.MAP_THIS_MARKER isnt 'undefined' and window.Nembrot.MAP_THIS_MARKER isnt 'rendered'
        this_marker = window.Nembrot.MAP_THIS_MARKER[0]
        window.Nembrot.map_object.serviceObject.panTo(new google.maps.LatLng(this_marker['lat'], this_marker['lng']))
        window.Nembrot.map_object.serviceObject.setZoom(16)
        window.Nembrot.MAP_THIS_MARKER = 'rendered' # REVIEW: delete window.Nembrot.MAP_THIS_MARKER does not work
      else
        window.Nembrot.map_handler.fitMapToBounds()

    else if typeof window.Nembrot.MAP_THIS_MARKER isnt 'undefined' and window.Nembrot.MAP_THIS_MARKER isnt 'rendered'
      render_map(map_container_id, window.Nembrot.MAP_THIS_MARKER, theme, false)
      window.Nembrot.map_object.serviceObject.setZoom(16)
      window.Nembrot.MAP_THIS_MARKER = 'rendered'

render_map = (map_container_id, markers, theme, show_map_type_control) ->
  map_style = window.Nembrot.THEMES[theme]['map_style']
  handler = (if map_container_id is 'single_map' then  Gmaps.build('Google') else Gmaps.build('Google', { builders: { Marker: RichMarkerBuilder } }))
  window.Nembrot.map_handler = handler

  window.Nembrot.map_object = handler.buildMap
    provider: {
        styles: window.Nembrot.map_styles[map_style],
        streetViewControl: show_map_type_control,
        mapTypeControl: show_map_type_control,
        mapTypeControlOptions: {
            style: google.maps.MapTypeControlStyle.HORIZONTAL_BAR,
            position: google.maps.ControlPosition.RIGHT_BOTTOM
        }
      }
    internal:
      id: map_container_id
  , ->
    markers = handler.addMarkers(markers)
    handler.bounds.extendWith markers
    handler.fitMapToBounds()
    $('#' + map_container_id).addClass('rendered')
    return

window.Nembrot.load_maps = load_maps

# Document hooks ******************************************************************************************************

$ ->
  $(document).pjax('#persistent_map .marker a', '[data-pjax-container]')

# Maps are loaded via the change_theme function
