add_thumbnails = () ->
  $('.thumbnails-module .notes ul li a[data-image-src]').each ->
    image = $('<img>',
      src: $(this).data('image-src')
      alt: $(this).data('image-alt')
    )
    $(this).prepend image
    $(this).removeAttr('data-image-src', 'data-image-alt')
    return

  $('.thumbnails-module .notes ul li a img').each ->
    $(this).show()

  $('html:not(.thumbnails-module) .notes ul li a img').each ->
    $(this).hide()

window.Nembrot.add_thumbnails = add_thumbnails

# Document hooks ******************************************************************************************************

$ ->
  add_thumbnails()

  $(document).on 'pjax:success', '#main', ->
    add_thumbnails()

  $(window).on 'popstate', ->
    add_thumbnails()
