# Need a shim for IE8 for NaturalWidth

load_hd_images = (tolerance = 120) ->
  $('figure.image').each ->
    # console.log($(this).parent().innerWidth())
    # console.log($(this).innerWidth())
    # console.log($(this).naturalWidth)
    # if $(this).parent().width() > ($(this).naturalWidth + tolerance)
    # console.log('Loading image...')
    image = $(this).find('img')
    source = image.attr('src')
    new_source = source.replace('16-9-8', '16-9-2048')
    image.attr('src', new_source)
    $(this).css('backgroundImage', "url(#{ new_source })")

# Document hooks ******************************************************************************************************

$ ->
  load_hd_images()

  $(document).on 'pjax:success', '#main', (data) ->
    load_hd_images()

  $(window).on 'popstate', ->
    load_hd_images()
