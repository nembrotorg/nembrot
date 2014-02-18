window.Nembrot.my_channels = []

mark_as_mine = () ->
  $('a').removeClass('mine')
  $.each window.Nembrot.my_channels, (i, e) ->
    $('a[href^="/' + e + '"]').addClass('mine')

# Document hooks ******************************************************************************************************

$ ->
  $(document).pjax('#tools a:not([href*=channels])', '[data-pjax-container]', { push: false })
  mark_as_mine()

$(document).on 'pjax:success', '#main', (data) ->
  mark_as_mine()
