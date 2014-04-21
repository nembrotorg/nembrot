# Need a shim for IE8 for NaturalWidth

load_hd_images = (tolerance = 120) ->
  $('figure.image').each ->
    container = $(this)
    image = $(this).find('img')
    image.on 'load', ->
      if container.width() > 800 # REVIEW Make this cleverer
        new_image = new Image
        new_source = image.attr('src').replace('16-9-8', '16-9-' + (parseInt container.width() / 10) * 10 )
        new_image.src = new_source
        $(new_image).on 'load', ->
          image.src = new_image.src
          container.css('backgroundImage', "url(#{ new_source })")

# Document hooks ******************************************************************************************************

$ ->
  load_hd_images()

  $(document).on 'pjax:success', '#main', (data) ->
    load_hd_images()

  $(window).on 'popstate', ->
    load_hd_images()
