place_annotations = () ->
  if $('html.wider-than-720px').length > 0
    place_annotations_do()
  else
    place_annotations_undo()

place_annotations_do = () ->
  if $('.annotations').length > 0
    $('.annotations').addClass('side-annotations')
    annotations = $('li[id^=annotation-]')
    minimum = $('.body').offset().top
    if $('#introduction').length then minimum += $('#introduction').outerHeight(true)
    if $('#single_map:visible').length > 0 then minimum += $('#single_map').outerHeight(true)
    new_top = minimum
    corrected_top = minimum

    annotations.each (i) ->
      new_top = $('a[id=annotation-mark-' + (i + 1) + ']').offset().top
      corrected_top = (if new_top <= minimum then minimum else new_top)
      minimum = corrected_top + $(this).outerHeight(true)
      $(this).offset top: corrected_top

    # _correct_annotations_from_bottom()

# Prevent notes from going below end of body text
_correct_annotations_from_bottom = () ->
  maximum = $('#text').offset().top + $('#text').outerHeight(false)
  annotations.reverse().each () ->
    if $(this).offset().top + $(this).outerHeight(true) >= maximum 
      maximum = $(this).offset().top - $(this).outerHeight(true)
      $(this).offset top: maximum

place_annotations_undo = () ->
  $('.annotations').removeClass('side-annotations')
  $('li[id*=annotation-]').css('top', '0')

# Document hooks ******************************************************************************************************

$ ->
  place_annotations()

  $(document).on 'pjax:success', '#main', (data) ->
    place_annotations()

  $(window).on 'popstate', ->
    place_annotations()

  $(window).on 'resize', ->
    place_annotations()
