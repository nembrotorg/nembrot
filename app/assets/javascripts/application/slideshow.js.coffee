initialize_slideshow = () ->
  $('.gallery').flexslider
    animationSpeed: (if Modernizr.touch then 400 else 1000)
    initDelay: 0
    pauseOnHover: true
    selector: 'li'
    slideshowSpeed: 7000

# Document hooks ******************************************************************************************************

$ ->
  initialize_slideshow()

  $(document).on 'pjax:success', '#main', (data) ->
    initialize_slideshow()

  $(window).on 'popstate', ->
    initialize_slideshow()
