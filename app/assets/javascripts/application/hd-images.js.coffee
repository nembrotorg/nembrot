# If the image is being stretched 'too much', replace it with a larger image

load_hd_images = (tolerance = 120) ->
  $('.hd-images-module figure.image.main-image .wrapper, .dashboard-open figure.image.main-image .wrapper').each ->
    container = $(this)
    image = $(this).find('img')
    image.on 'load', ->
      if container.width() > 800 && image.attr('src').indexOf('16-9-8') != -1
        new_image = new Image
        new_source = image.attr('src').replace('16-9-8', '16-9-' + (Math.ceil(container.width() / 100) * 100))
        new_image.src = new_source
        $(new_image).on 'load', ->
          container.css('backgroundImage', "url(#{ new_source })")
          image.attr('src', new_image.src)

window.Nembrot.load_hd_images = load_hd_images

# Document hooks ******************************************************************************************************

$ ->
  load_hd_images()

  $(document).on 'pjax:success', '#main', (data) ->
    load_hd_images()

  $(window).on 'popstate', ->
    load_hd_images()

  $(window).on 'resize', ->
    load_hd_images()
