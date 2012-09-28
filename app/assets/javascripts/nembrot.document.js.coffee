page_initializers = () ->
  $('a:not([data-remote]):not([data-behavior]):not([data-skip-pjax])').pjax('[data-pjax-container]');

content_initializers = () ->
  $('time').timeago()

  # THIS SHOULD NOT BE NECESSARY
  # NEEDS TO BE MORE THOROUGH, INCLUDE OVERALL TITLE AND UPDATE OTHER TAGS
  if $('hgroup').data('title')
    document.title = $('hgroup').data('title')

$ ->
  page_initializers()
  content_initializers()

$(document).on 'pjax:end', ->
  content_initializers()
