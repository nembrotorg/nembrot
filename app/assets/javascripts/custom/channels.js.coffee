window.Nembrot.my_channels = []

track_channel_view = () ->
  if $('[data-channel-name]').data('channel-name') then ga('set', 'dimension1', $('[data-channel-name]').data('channel-name'))

# Document hooks ******************************************************************************************************

$ ->
  track_channel_view()
