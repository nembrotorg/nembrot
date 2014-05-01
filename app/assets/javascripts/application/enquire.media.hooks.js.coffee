# REVIEW: Since enquire.js is event-based rather than query-based, and we need to test viewport widths
#  every time we load new content, we need to use this:

register_enquire_media_hooks = () ->
  enquire.register 'screen and (min-width: 720px)',
    match: ->
      $('html').addClass('wider-than-720px')
    unmatch: ->
      $('html').removeClass('wider-than-720px')

  enquire.register 'screen and (min-width: 1024px)',
    match: ->
      $('html').addClass('wider-than-1024px')
    unmatch: ->
      $('html').removeClass('wider-than-1024px')

# Document hooks ******************************************************************************************************

$ ->
  register_enquire_media_hooks()
