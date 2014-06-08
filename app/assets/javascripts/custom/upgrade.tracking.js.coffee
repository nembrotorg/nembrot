track_paypal = (link, plan) ->
  try
    ga('send', 'event', 'Upgrade motivator', 'channel', $('[data-theme]').data('channel-name'))
    ga('send', 'event', 'Upgrade motivator', 'path', location.pathname)
    ga('send', 'event', 'Upgrade motivator', 'theme', $('[data-theme]').attr('data-theme'))
    ga('send', 'event', 'Upgrade motivator', 'incentive', $('#upgrade_alert #message strong').data('category'))
    ga('send', 'event', 'Upgrade', 'pay', plan)

  setTimeout (->
    document.location.href = link
  ), 100

track_evernote_connect = (link, category, action) ->
  try
    ga('send', 'event', 'Connect motivator', 'channel', $('[data-theme]').data('channel-name'))
    ga('send', 'event', 'Connect motivator', 'path', location.pathname)
    ga('send', 'event', 'Connect motivator', 'theme', $('[data-theme]').attr('data-theme'))
    ga('send', 'event', category, action)

  setTimeout (->
    document.location.href = link
  ), 100

track_dashboard = () ->
  if $('#dashboard #channel-created').length > 0
    ga('send', 'event', 'Channel', 'created')

  if $('#dashboard #channel-updated').length > 0
    ga('send', 'event', 'Channel', 'updated')

  if $('#dashboard #cancelled-upgrade').length > 0
    ga('send', 'event', 'Upgrade', 'cancelled')

  if $('#dashboard #successful-upgrade').length > 0
    ga('send', 'event', 'Upgrade', 'successful')

  if $('#dashboard #Evernote-connected').length > 0
    ga('send', 'event', 'Evernote', 'connected')

window.Nembrot.track_dashboard = track_dashboard

# Document hooks ******************************************************************************************************

$ ->
  $(document).on 'click', '#dashboard a[href="/users/auth/evernote"]', ->
    track_evernote_connect(@href, 'Evernote', 'connect')
    false

  $(document).on 'click', '#dashboard #pay-monthly', ->
    track_paypal(@href, 'monthly')
    false

  $(document).on 'click', '#dashboard #pay-yearly', ->
    track_paypal(@href, 'yearly')
    false
