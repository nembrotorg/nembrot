place_annotations = () ->
  if $('html.wider-than-720px').length > 0
    place_annotations_do()
  else
    place_annotations_undo()

place_annotations_do = () ->
  if $('#annotations').length > 0
    $('#annotations').addClass('side-annotations')
    annotations = $('li[id^=annotation-]')
    minimum = $('.body').offset().top
    if $('#single_map:visible').length > 0 then minimum += $('#single_map').outerHeight(true)
    new_top = minimum
    corrected_top = minimum

    annotations.each (i) ->
      new_top = $('a[id=annotation-mark-' + (i + 1) + ']').offset().top
      corrected_top = (if new_top <= minimum then minimum else new_top)
      minimum = corrected_top + $(this).outerHeight(true)
      $(this).offset top: corrected_top

    _correct_annotations_from_bottom(annotations)

# Prevent notes from going below end of body text
_correct_annotations_from_bottom = (annotations) ->
  reversed_annotations = annotations.reverse()
  maximum = $('#text .body').offset().top + $('#text .body').outerHeight(false)

  summed_heights = _.reduce(reversed_annotations, ((memo, num) ->
    memo + $(num).outerHeight(true)
  ), 0)

  # Only do this second pass if there is enough space
  if $('#text .body').outerHeight(false) > summed_heights
    reversed_annotations.each () ->
      this_top = $(this).offset().top
      this_bottom = $(this).offset().top + $(this).outerHeight(true)
      new_top = (if this_bottom > maximum then (maximum - $(this).outerHeight(true)) else this_top)
      $(this).offset top: new_top
      maximum = new_top

place_annotations_undo = () ->
  $('#annotations').removeClass('side-annotations')
  $('li[id*=annotation-]').css('top', '0')

window.Nembrot.place_annotations = place_annotations
