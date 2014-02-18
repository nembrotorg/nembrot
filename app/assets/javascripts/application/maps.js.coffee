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
  map_container = $('.map').filter(':visible').attr('id')
  if typeof map_container != 'undefined' && typeof gon.map != 'undefined'
    handler = Gmaps.build('Google',
      builders:
        Marker: RichMarkerBuilder
    )

    handler.buildMap
      provider: {}
      internal:
        id: map_container
    , ->
      markers = handler.addMarkers(gon.map)
      handler.bounds.extendWith markers
      handler.fitMapToBounds()
      return

# Document hooks ******************************************************************************************************

$ ->
  $(document).pjax('.persistent_map a.marker', '[data-pjax-container]', { push: false })
  load_maps()

$(document).on 'pjax:success', '#main', (data) ->
  load_maps()
