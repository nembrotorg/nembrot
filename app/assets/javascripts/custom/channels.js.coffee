window.Nembrot.my_channels = []

mark_as_mine = () ->
  $('a').removeClass('mine')
  $.each window.Nembrot.my_channels, (i, e) ->
    $('a[href^="/' + e + '"]').addClass('mine')

track_channel_view = () ->
  if $('[data-channel-name]').data('channel-name') then ga('set', 'dimension1', $('[data-channel-name]').data('channel-name'))

# Document hooks ******************************************************************************************************

$ ->
  $(document).pjax('#tools a:not([href*=channels])', '[data-pjax-container]', { push: false })
  mark_as_mine()
  track_channel_view()

$(document).on 'pjax:success', '#main', (data) ->
  mark_as_mine()
