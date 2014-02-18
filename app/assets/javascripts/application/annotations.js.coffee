place_annotations = () ->
  if $('.annotations').length
    (if _media_query('default') then _place_annotations_undo() else _place_annotations_do())
    # $('#text').addClass('fade-annotations') (This should be a command, maybe 'distraction-free')
  true

_media_query = (media_query_string) ->
  style = null
  if window.getComputedStyle and window.getComputedStyle(document.body, '::after')
    style = window.getComputedStyle(document.body, '::after')
    style = style.content.replace /"/g, ''
  style is media_query_string

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
    minimum = corrected_top + $(this).outerHeight(true)
    $(this).offset top: corrected_top

  # _correct_annotations_from_bottom()

# Prevent notes from going below end of body text
_correct_annotations_from_bottom = () ->
  maximum = $('#text').offset().top + $('#text').outerHeight(false)
  annotations.reverse().each () ->
    if $(this).offset().top + $(this).outerHeight(true) >= maximum 
      maximum = $(this).offset().top - $(this).outerHeight(true)
      $(this).offset top: maximum

_place_annotations_undo = () ->
  $('.annotations').removeClass('side-annotations')
  $('li[id*=annotation-]').css('top', '0')

# Document hooks ******************************************************************************************************

$ ->
  place_annotations()

$(document).on 'pjax:success', '#main', (data) ->
  place_annotations()

$(window).on 'resize', ->
  place_annotations()
