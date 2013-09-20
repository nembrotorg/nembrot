jQuery.fn.reverse = [].reverse

page_initializers = () ->
  $('a:not([data-remote]):not([data-behavior]):not([data-skip-pjax])').pjax('[data-pjax-container]');

content_initializers = () ->
  $('time').timeago()

  # REVIEW: Either use pjax-rack, or loop through title and all meta tags
  title_data = $('#main section:first-of-type').data('title')
  if title_data
    document.title = title_data

  place_annotations()

resize_initializers = () ->
  place_annotations()

place_annotations = () ->
  if $('.annotations').length
    (if _media_query('default') then _place_annotations_undo() else _place_annotations_do())
    $('#text').addClass('fadeable-annotations')
  true

_place_annotations_do = () ->
  $('.annotations').addClass('side-annotations')
  annotations = $('li[id*=annotation-]')
  minimum = 0
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

$ ->
  page_initializers()
  content_initializers()

$(document).on 'pjax:end', ->
  content_initializers()

$(window).on 'resize', ->
  resize_initializers()
