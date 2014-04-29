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

Modernizr.load
  test: Modernizr.matchMedia
  yep: ['/assets/polyfills/match_media-aa9b7ff314a1a6548fb5c9a78f63b8f4.js'] # REVIEW: This is very fragile
  complete: -> register_enquire_media_hooks()
