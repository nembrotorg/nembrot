add_thumbnails = () ->
  $('.thumbnails-module .notes ul li a[data-image-src]').each ->
    figure = $('<figure>',
      class: 'image'
    )
    wrapper = $('<div>',
      class: 'wrapper',
      style: 'background: url(' + $(this).data('image-src') + ')'
    )
    image = $('<img>',
      src: $(this).data('image-src')
      alt: $(this).data('image-alt')
    )
    figure.prepend wrapper
    wrapper.prepend image
    $(this).prepend figure
    $(this).removeAttr('data-image-src', 'data-image-alt')
    return

  $('.thumbnails-module .notes ul li a figure.image').each ->
    $(this).show()

  $('html:not(.thumbnails-module) .notes ul li a figure.image').each ->
    $(this).hide()

window.Nembrot.add_thumbnails = add_thumbnails

# Document hooks ******************************************************************************************************

$ ->
  add_thumbnails()

  $(document).on 'pjax:success', '#main', ->
    add_thumbnails()

  $(window).on 'popstate', ->
    add_thumbnails()
