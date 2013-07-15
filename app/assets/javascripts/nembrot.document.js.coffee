page_initializers = () ->
  $('a:not([data-remote]):not([data-behavior]):not([data-skip-pjax])').pjax('[data-pjax-container]');

content_initializers = () ->
  $('time').timeago()

  # THIS SHOULD NOT BE NECESSARY
  # NEEDS TO BE MORE THOROUGH, INCLUDE OVERALL TITLE AND UPDATE OTHER TAGS
  if $('hgroup').data('title')
    document.title = $('hgroup').data('title')

  format_annotations()

format_annotations = () ->
  minimum = 0
  new_top = undefined
  corrected_top = undefined
  $("li[id*=annotation-]").each (i) ->
    new_top = $("a[id=annotation-mark-" + (i + 1) + "]").offset().top
    corrected_top = (if new_top <= minimum then minimum else new_top)
    minimum = new_top + $(this).outerHeight(true)
    $(this).offset top: corrected_top

$ ->
  page_initializers()
  content_initializers()

$(document).on 'pjax:end', ->
  content_initializers()
