page_initializers = () ->
  $('a:not([data-remote]):not([data-behavior]):not([data-skip-pjax])').pjax('[data-pjax-container]');

content_initializers = () ->
  $('time').timeago()

  # THIS SHOULD NOT BE NECESSARY
  # NEEDS TO BE MORE THOROUGH, INCLUDE OVERALL TITLE AND UPDATE OTHER TAGS
  if $('hgroup').data('title')
    document.title = $('hgroup').data('title')

  # needs to happen on resize
  place_annotations()

place_annotations = () ->
  (if media_query('screen-and-min-width-1024px') then _place_annotations_do() else _place_annotations_undo())
  true

_place_annotations_do = () ->
  minimum = 0
  new_top = undefined
  corrected_top = undefined
  $("li[id*=annotation-]").each (i) ->
    new_top = $("a[id=annotation-mark-" + (i + 1) + "]").offset().top
    corrected_top = (if new_top <= minimum then minimum else new_top)
    minimum = new_top + $(this).outerHeight(true)
    $(this).offset top: corrected_top

_place_annotations_undo = () ->
  $("li[id*=annotation-]").offset top: 'auto'

media_query = (media_query_string) ->
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

$(document).on 'resize', ->
  place_annotations()
