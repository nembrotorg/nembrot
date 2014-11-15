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
  channel = $('[data-channel-name]').data('channel-name')

  if typeof map_container_id isnt 'undefined'
    if map_container_id is 'persistent_map'
      if typeof window.Nembrot.MAP_ALL_MARKERS isnt 'undefined' and (!map_container.hasClass('rendered') or map_container.data('theme') isnt theme or map_container.data('channel') isnt channel)
        render_map(map_container_id, window.Nembrot.MAP_ALL_MARKERS, theme, true)

      if typeof window.Nembrot.MAP_THIS_MARKER isnt 'undefined' and window.Nembrot.MAP_THIS_MARKER isnt 'rendered'
        this_marker = window.Nembrot.MAP_THIS_MARKER[0]
        window.Nembrot.map_object.serviceObject.panTo(new google.maps.LatLng(this_marker['lat'], this_marker['lng']))
        window.Nembrot.map_object.serviceObject.setZoom(16)
        window.Nembrot.MAP_THIS_MARKER = 'rendered' # REVIEW: delete window.Nembrot.MAP_THIS_MARKER does not work
      else if window.Nembrot.map_handler isnt 'undefined'
        window.Nembrot.map_handler.fitMapToBounds()

      setTimeout build_tags, 2000 # REVIEW: Use a suitable callback

    else if typeof window.Nembrot.MAP_THIS_MARKER isnt 'undefined' and window.Nembrot.MAP_THIS_MARKER isnt 'rendered'
      render_map(map_container_id, window.Nembrot.MAP_THIS_MARKER, theme, false)
      window.Nembrot.map_object.serviceObject.setZoom(16)
      window.Nembrot.MAP_THIS_MARKER = 'rendered'

    else
      # If we do not render the map, Firefox keeps trying to load the Google maps API
      render_map($('figure.map_container .map'), {}, theme, false)

render_map = (map_container_id, markers, theme, show_map_type_control) ->
  map_style = window.Nembrot.THEMES[theme]['map_style']
  handler = (if map_container_id is 'single_map' then  Gmaps.build('Google') else Gmaps.build('Google', { builders: { Marker: RichMarkerBuilder } }))
  window.Nembrot.map_handler = handler
  channel = $('[data-channel-name]').data('channel-name')

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
    $('#' + map_container_id).addClass('rendered').data('theme', theme).data('channel', channel)
    return

build_tags = () ->
  if $('#persistent_map ol#tags').length == 0
    all_tags = ''
    _.each $('#persistent_map .marker a'), (marker) ->
      all_tags += ', ' + $(marker).data('tags')

    tags = all_tags.split ', '
    tags = _.compact tags
    tags = tags.sort()
    tags = _.uniq tags, true

    list = $('<ol>', { id: 'tags' } )

    _.each tags, (tag) ->
      itemx = $('<li>')
      labelx = $('<label>')
      labelx.append $('<input>', { checked: true, type: 'checkbox', value: tag } )
      labelx.append "#{ tag }"
      itemx.append labelx
      list.append itemx

    $('#persistent_map').append list

    if $('[data-controller="tags"][data-action="show"]').length > 0
      show_one_map_tag $('#main h1').text()

    $(document).on 'click', '#persistent_map ol#tags input', () ->
      update_map_tags()

update_map_tags = () ->
  all_checked_inputs = $('#persistent_map ol#tags input:checked')
  all_selected_tags = _.map all_checked_inputs, (input) ->
    input.value
  update_map_markers_according_to_tags(all_selected_tags)

show_one_map_tag = (tag_list) ->
  if $('#persistent_map ol#tags').length > 0
    tags = tag_list.split(/, ?/)
    update_map_markers_according_to_tags(tags)
    $('#persistent_map ol#tags input').prop('checked', false)
    _.each tags, (tag) ->
      $("#persistent_map ol#tags input[value=\"#{ tag }\"]").prop('checked', true)

update_map_markers_according_to_tags = (all_selected_tags) ->
  _.each $('#persistent_map .marker'), (marker) ->
    required_tags_for_marker = _.intersection $(marker).find('a').data('tags').split(/, ?/), all_selected_tags
    if _.isEmpty required_tags_for_marker then $(marker).hide() else $(marker).show()

window.Nembrot.load_maps = load_maps
window.Nembrot.show_one_map_tag = show_one_map_tag

# Document hooks ******************************************************************************************************

$ ->
  $(document).pjax('#persistent_map .marker a', '[data-pjax-container]')

# Maps are loaded via the change_theme function
