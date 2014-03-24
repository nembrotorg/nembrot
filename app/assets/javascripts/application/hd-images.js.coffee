# Need a shim for IE8 for NaturalWidth

load_hd_images = (tolerance = 120) ->
  $('figure.image img').each ->
    # console.log($(this).parent().innerWidth())
    # console.log($(this).innerWidth())
    # console.log($(this).naturalWidth)
    # if $(this).parent().width() > ($(this).naturalWidth + tolerance)
    # console.log('Loading image...')
    $(this).attr('src', $(this).attr('src').replace('16-9-8', '16-9-2048'))

# Document hooks ******************************************************************************************************

$ ->
  load_hd_images()

  $(document).on 'pjax:success', '#main', (data) ->
    load_hd_images()

  $(window).on 'popstate', ->
    load_hd_images()
