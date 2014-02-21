# SEE: 
#  https://github.com/kangaroo5383/google-maps-utility-library-v3/blob/master/richmarker/examples/richmarker.html
#  https://github.com/apneadiving/Google-Maps-for-Rails/wiki/Change-handler-behavior

class RichMarkerBuilder extends Gmaps.Google.Builders.Marker
  create_marker: ->
    options = _.extend @marker_options(), @rich_marker_options()
    alert
    @serviceObject = new RichMarker options #assign marker to @serviceObject

  rich_marker_options: ->
    marker = document.createElement('div')
    marker.setAttribute 'class', 'marker'
    marker.innerHTML = @args.marker
    _.extend @marker_options(), { content: marker, flat: true, anchor: RichMarkerPosition.MIDDLE_LEFT }

load_maps = (map) ->
  map_container = $('figure.map_container:visible .map').attr('id')
  if typeof map_container != 'undefined' && typeof window.Nembrot.MAP != 'undefined'
    # Also add map style as used below, so that markers can be styled accordingly
    handler = Gmaps.build('Google',
      builders:
        Marker: RichMarkerBuilder
    )

    handler.buildMap
      provider: { styles: window.Nembrot.map_styles['greyscale'] } # This should come from theme
      internal:
        id: map_container
    , ->
      markers = handler.addMarkers(window.Nembrot.MAP)
      handler.bounds.extendWith markers
      handler.fitMapToBounds()
      return

window.Nembrot.load_maps = load_maps

# Document hooks ******************************************************************************************************

$ ->
  $(document).pjax('.persistent_map a.marker', '[data-pjax-container]', { push: false })
  load_maps()

$(document).on 'pjax:success', '#main', (data) ->
  load_maps()
