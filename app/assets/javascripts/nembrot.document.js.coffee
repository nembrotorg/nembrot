jQuery.fn.reverse = [].reverse

update_titles = () ->
  title_data = $('#main header:first-of-type').data('title')
  if title_data
    document.title = title_data

track_page_view = () ->
  _gaq = window._gaq ?= []
  _gaq.push(['_trackPageview', location.pathname])

track_outbound_link = (link, category, action) ->
  try
    _gaq.push ['_trackEvent', category, action, link]

  setTimeout (->
    document.location.href = link
  ), 100

track_download = (link, category, action, which) ->
  try
    _gaq.push ['_trackEvent', category, action, link, which]

place_annotations = () ->
  if $('.annotations').length
    (if _media_query('default') then _place_annotations_undo() else _place_annotations_do())
    $('#text').addClass('fadeable-annotations')
  true

_place_annotations_do = () ->
  $('.annotations').addClass('side-annotations')
  annotations = $('li[id^=annotation-]')
  minimum = $('.body').offset().top
  if $('#map').length then minimum += $('#map').outerHeight(true)
  new_top = minimum
  corrected_top = minimum

  annotations.each (i) ->
    new_top = $('a[id=annotation-mark-' + (i + 1) + ']').offset().top
    corrected_top = (if new_top <= minimum then minimum else new_top)
    minimum = new_top + $(this).outerHeight(true)
    $(this).offset top: corrected_top

  maximum = $('#text').offset().top + $('#text').outerHeight(false)
  annotations.reverse().each () ->
    if $(this).offset().top + $(this).outerHeight(true) >= maximum 
      maximum = $(this).offset().top - $(this).outerHeight(true)
      $(this).offset top: maximum

_place_annotations_undo = () ->
  $('.annotations').removeClass('side-annotations')
  $('li[id*=annotation-]').css('top', '0')

_media_query = (media_query_string) ->
  style = null
  if window.getComputedStyle and window.getComputedStyle(document.body, '::after')
    style = window.getComputedStyle(document.body, '::after')
    style = style.content.replace /"/g, ''
  style is media_query_string

reload_shares = () ->
  FB.XFBML.parse()
  gapi.plusone.go()
  twttr.widgets.load()

fix_facebook_dialog = () ->
  $('.fb-like span').css('width', $('.fb-like').data('width'))
  alert('innit')


# Document hooks ******************************************************************************************************

$ ->
  document_initializers()

$(document).on 'pjax:end', ->
  content_initializers()
  content_initializers_reload_only()

$(window).on 'resize', ->
  resize_initializers()

# Initializers ********************************************************************************************************

document_initializers = () ->
  # Implementing a spinner may be a better idea: https://github.com/defunkt/jquery-pjax/issues/129
  $.pjax.defaults.timeout = false
  $(document).pjax('a:not([data-remote]):not([data-behavior]):not([data-skip-pjax])', '[data-pjax-container]')

  $(document).on 'click', 'a[href^=http]', ->
    track_outbound_link(this.href, 'Outbound Link', this.href.toString().replace(/^https?:\/\/([^\/?#]*).*$/, '$1'))
    false

  $(document).on 'mousedown', "a[href$='.pdf'], a[href$='.zip']", (event) ->
    track_download(this.href.toString().replace(/^https?:\/\/([^\/?#]*)(.*$)/, '$2'), 'Download', this.text, event.which)

  $(document).on 'click', '.fb-like', ->
    fix_facebook_dialog()

  content_initializers()

content_initializers = () ->
  $('time').timeago()
  update_titles()
  track_page_view()
  resize_initializers()
  # Gmaps.loadMaps()

content_initializers_reload_only = () ->
  reload_shares()
  Gmaps.loadMaps()

resize_initializers = () ->
  place_annotations()
