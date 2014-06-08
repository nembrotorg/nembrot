track_page_view = () ->
  ga('send', 'pageview', location.pathname)

track_outbound_link = (link, category, action) ->
  try
    ga('send', 'event', category, action, link)

  setTimeout (->
    document.location.href = link
  ), 100

track_social = (link, category, action) ->
  try
    ga('send', 'social', category, action, location.pathname)

  setTimeout (->
    document.location.href = link
  ), 100

track_download = (link, action, which) ->
  try
    ga('send', 'event', 'Downloads', action, link, which)

track_comment = (action) ->
  try
    ga('send', 'event', 'Comments', action, link, location.pathname)

window.Nembrot.track_comment = track_comment

# Document hooks ******************************************************************************************************

$ ->
  track_page_view()

  $(document).on 'pjax:success', '#main', ->
    track_page_view()

  $(window).on 'popstate', ->
    track_page_view()

  $(document).on 'click', '#main a[href^=http]:not(.share a)', ->
    track_outbound_link(@href, 'Outbound Link', @href.toString().replace(/^https?:\/\/([^\/?#]*).*$/, '$1'))
    false

  $(document).on 'mousedown', "a[href$='.pdf'], a[href$='.zip']", (event) ->
    track_download(@href.toString().replace(/^https?:\/\/([^\/?#]*)(.*$)/, '$2'), @text, event.which)

  $(document).on 'click', '.share a[href*=facebook]', ->
    track_social(@href, 'facebook', 'like')
    false

  $(document).on 'click', '.share a[href*=google]', ->
    track_social(@href, 'google+', 'share')
    false

  $(document).on 'click', '.share a[href*=twitter]', ->
    track_social(@href, 'twitter', 'tweet')
    false
