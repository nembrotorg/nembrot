jQuery.fn.reverse = [].reverse

# See http://api.jquery.com/jquery.getscript/
jQuery.cachedScript = (url, options) ->
  options = $.extend(options or {},
    dataType: 'script'
    cache: true
    url: url
  )

  jQuery.ajax options

window.Nembrot ?= {}
window.Nembrot.my_channels = []

update_titles = () ->
  title_data = $('#main header:first-of-type').data('title')
  if title_data
    document.title = title_data

track_page_view = () ->
  ga('send', 'pageview', location.pathname)
  if $('[data-channel-name]').data('channel-name') then ga('set', 'dimension1', $('[data-channel-name]').data('channel-name'))

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

place_annotations = () ->
  if $('.annotations').length
    (if _media_query('default') then _place_annotations_undo() else _place_annotations_do())
    # $('#text').addClass('fade-annotations') (This should be a command, maybe 'distraction-free')
  true

_place_annotations_do = () ->
  $('.annotations').addClass('side-annotations')
  annotations = $('li[id^=annotation-]')
  minimum = $('.body').offset().top
  if $('#map').length then minimum += $('#map').outerHeight(true)
  new_top = minimum
  corrected_top = minimum

  annotations.each (i) ->
    new_top = $('a[id=annotation-mark-' + (i + 1) + ']').offset().top
    corrected_top = (if new_top <= minimum then minimum else new_top)
    minimum = corrected_top + $(this).outerHeight(true)
    $(this).offset top: corrected_top

  # Prevent notes from going below end of body text
  # maximum = $('#text').offset().top + $('#text').outerHeight(false)
  # annotations.reverse().each () ->
  #   if $(this).offset().top + $(this).outerHeight(true) >= maximum 
  #     maximum = $(this).offset().top - $(this).outerHeight(true)
  #     $(this).offset top: maximum

_place_annotations_undo = () ->
  $('.annotations').removeClass('side-annotations')
  $('li[id*=annotation-]').css('top', '0')

_media_query = (media_query_string) ->
  style = null
  if window.getComputedStyle and window.getComputedStyle(document.body, '::after')
    style = window.getComputedStyle(document.body, '::after')
    style = style.content.replace /"/g, ''
  style is media_query_string

load_share_links_in_iframes = () ->
  FB.XFBML.parse()
  gapi.plusone.go()
  twttr.widgets.load()

# From Sharrre plug-in https://raw.github.com/Julienh/Sharrre/master/jquery.sharrre.js
# https://graph.facebook.com/fql?q=SELECT%20url,%20normalized_url,%20share_count,%20like_count,%20comment_count,%20tot
#  al_count,commentsbox_count,%20comments_fbid,%20click_count%20FROM%20link_stat%20WHERE%20url=%27{url}%27&callback=?"

FACEBOOK_API_URL = 'http://graph.facebook.com/'
TWITTER_API_URL = "http://cdn.api.twitter.com/1/urls/count.json"

load_share_links = (page_action) ->
  if page_action == 'show'
    $('.share').addClass('deep-link')
    title = $('h1').text().trim()
    url = encodeURIComponent(location.href)
  else
    $('.share').removeClass('deep-link')
    title = 'nembrot.com'
    url = 'http://' + encodeURIComponent(location.host)

  $('#tools a[href*=facebook]').attr('href', 'http://www.facebook.com/share.php?u=' + url + '&title=' + title)
  $('#tools a[href*=twitter]').attr('href', 'http://twitter.com/home?status=' + title + '+' + url)
  $('#tools a[href*=google]').attr('href', 'https://plus.google.com/share?url=' + url)

  #facebook_count = get_facebook_count(url)
  #twitter_count = get_twitter_count(url)
  # Get googleplus: https://gist.github.com/jonathanmoore/2640302

  #$('#tools #tools_counter').remove()
  #$('#tools').append("<style id='#tools_counter'>#tools a[href*=facebook]:after{ content:'" + facebook_count + "' };#tools a[href*=twitter]:after{ content: '" + twitter_count + "' };</style>")

get_facebook_count = (url) ->
  $.getJSON FACEBOOK_API_URL + url, (data) ->
    facebook_count = _normalize_count(data.shares)
    facebook_count = shorter_total(facebook_count)
    facebook_count

get_twitter_count = (url) ->
  $.getJSON TWITTER_API_URL + "?callback=?&url=" + url, (data) ->
    twitter_count = _normalize_count(data.count)
    twitter_count = shorter_total(twitter_count)
    twitter_count

DISQUS_API_KEY = 'qibvGX1OhK1EDIGCsc0QMLJ0sJHSIKVLLyCnwE3RZPKkoQ7Dj0Mm1oUS8mRjLHfq'
DISQUS_API_URL = 'https://disqus.com/api/3.0/threads/set.jsonp'

load_disqus_comments_count = (page_controller, page_action) ->
  if (page_controller == 'notes' && page_action == 'show') || page_controller == 'features'
    $('.page').addClass('deep-link')
    $.getJSON DISQUS_API_URL + "?api_key=" + DISQUS_API_KEY + "&forum=" + window.Nembrot.DISQUS_SHORT_NAME + "&thread=" + encodeURIComponent(location.href), (data) ->
      count = _normalize_count(data.response.first)
    $('#tools a[href$="#comments"]').text(count)
  else
    $('.page').removeClass('deep-link')
    $('#tools a[href$="#comments"]').text('')

load_comments_count = (page_controller, page_action) ->
  if (page_controller == 'notes' && page_action == 'show') || page_controller == 'features'
    $('.page').addClass('deep-link')
    count = RegExp(/\d+/).exec($('#comments h2').text())
    if count == null then count = ''
    $('#tools a[href$="#comments"]').text(count)
  else
    $('.page').removeClass('deep-link')
    $('#tools a[href$="#comments"]').text('')

_normalize_count = (data) ->
    count = ''
    count = data
    if count == 0 then count = ''
    count

shorter_total = (num) ->
  if num >= 1e6
    num = (num / 1e6).toFixed(2) + "M"
  else if num >= 1e3
    num = (num / 1e3).toFixed(1) + "k"
  num

fix_facebook_dialog = () ->
  $('.fb-like span').css('width', $('.fb-like').data('width'))

insert_qr_code = () ->
  # Get image size from settings
  $('body > footer img.qr_code').remove()
  $('body > footer').prepend('<img class="qr_code" src="https://chart.googleapis.com/chart?chs=150x150&cht=qr&chl=' + location.href + '" alt="QR code">')

add_scrolling_class = () ->
  clearTimeout(window.scrolling)
  $('body').addClass('scrolling')
  window.scrolling = setTimeout(->
    $('body').removeClass('scrolling')
  , 3000)

load_user_menu = () ->
  $.ajax
    url: '/users/menu'
    cache: false
    success: (html) ->
      $('#tools .user').html(html)

window.Nembrot.load_user_menu = load_user_menu

load_dashboard = () ->
  $.ajax
    url: '/channels/choose/' + String($('[data-channel-slug]').data('channel-slug'))
    cache: false
    success: (html) ->
      $('#dashboard').html(html)

window.Nembrot.load_dashboard = load_dashboard

TYPEKITS =
  nembrot: 'crv1apl'
  dark: 'crv1apl'
  leipzig: 'qho7ezg'
  meta: 'crv1apl'
  home: 'srt1pbp'
  magazine: 'jix2vil'

change_theme = (theme) ->
  load_typekit_font(TYPEKITS[theme])
  $('html, [data-theme]').alterClass('theme-*', 'theme-' + theme)

viewing_and_editing_same_channel = () ->
  String($('[data-channel-id]').data('channel-id')) == String($('#dashboard .channels-edit input[name=id]').val())

load_typekit_font = (name) ->
  $.cachedScript('//use.typekit.net/' + name + '.js').done (script) ->
    try
      Typekit.load()

window.Nembrot.load_typekit_font = load_typekit_font

mark_as_mine = () ->
  $('a').removeClass('mine')
  $.each window.Nembrot.my_channels, (i, e) ->
    $('a[href^="/' + e + '"]').addClass('mine')

# Initializers ********************************************************************************************************

document_initializers = () ->
  # Implementing a spinner may be a better idea: https://github.com/defunkt/jquery-pjax/issues/129
  $.pjax.defaults.timeout = false
  $(document).pjax('#dashboard a:not(.show-channel)', '[data-pjax-dashboard]', { cache: false, push: false } )
  $(document).pjax('#tools a:not([href*=channels]), #main a:not(.mine):not([data-remote])', '[data-pjax-container]', { push: false })
  $(document).pjax('#main a.mine', '[data-pjax-container]', { cache: false, push: false })
  $(document).pjax('#dashboard a.show-channel:not([data-remote])', '[data-pjax-container]', { cache: false, push: false })

  $(document).on 'submit', '#dashboard form', (event) ->
    $.pjax.submit event, '[data-pjax-dashboard]', { push: false }

  $(document).on 'submit', '#main section:not(#comments) form', (event) ->
    $.pjax.submit event, '[data-pjax-container]'

  $(document).on 'click', 'a[href^=http]:not(.share a)', ->
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

  $(document).on 'click', '.fb-like', ->
    fix_facebook_dialog()

  $(document).on 'touchmove', 'body', ->
    add_scrolling_class()

  $(document).on 'keyup', (event) ->
    if event.keyCode == 27 && $('[data-theme-wrapper]').data('channel_slug') != 'default' then $('#dashboard').fadeOut() # REVIEW: Genericise

  $(window).scroll ->
    add_scrolling_class()

  $(window).mousemove ->
    clearTimeout(window.mousemoving)
    $('body').addClass('mousemoving')
    window.mousemoving = setTimeout(->
      $('body').removeClass('mousemoving')
    , 3000)

  # REVIEW: nembrot.com-specific scripts should go in separate Javascript file, and included unobtrusively
  $(document).on 'change', '#dashboard input[name="channel[theme]"]', ->
    if viewing_and_editing_same_channel() then change_theme(@value)

  # Automatically open name panel when a notebook is selected, if this is a new channel
  $(document).on 'click', '#dashboard .notebooks label', ->
    if $("#dashboard .name input").val() == ''
      setTimeout (->
        $('#dashboard .notebooks legend').addClass('completed')
        $('#dashboard form').accordion 'option', 'active', 2
        $("#dashboard .name input").focus()
      ), 500

  $(document).on 'click', '#tools a[href*=channels]', (event) ->
    event.preventDefault()
    $('#dashboard').fadeToggle()
    if $('#dashboard').is(':visible') then load_dashboard()

  $(document).on 'click', 'a[href="#close"]', (event) ->
    event.preventDefault()
    $(event.target).parent().fadeOut()

  content_initializers()

  load_user_menu()

  $('#dashboard').draggable()

  # REVIEW: This isn't working at the moment
  #  There's a hardcoded script at the end of form.
  #  Also we need to open .active
  # $('#dashboard form').accordion header: 'legend'

content_initializers = () ->
  $('time').timeago()
  update_titles()
  track_page_view()
  resize_initializers()
  insert_qr_code()
  mark_as_mine()

  page_controller = $('[data-controller]').data('controller');
  page_action = $('[data-action]').data('action');
  load_share_links(page_action)
  # if $('#disqus_thread').length > 0 then load_disqus_comments_count(page_controller, page_action) # Check Settings first
  if $('#comments').length > 0 then load_comments_count(page_controller, page_action)

  if location.pathname == '/' && $('#dashboard').not(':visible')
    load_dashboard()
    $('#dashboard').show()

window.Nembrot.content_initializers = content_initializers

content_initializers_reload_only = () ->
  change_theme($('[data-theme]').data('theme'))

  # if $('#disqus_thread').length > 0
  # DISQUS.reset
  #    reload: true
  #    config: ->
  #      @page.title = $('h1').text()
  #      @language = $('html').attr('lang')
  #      return

resize_initializers = () ->
  place_annotations()

# Document hooks ******************************************************************************************************

$ ->
  document_initializers()

$(document).on 'pjax:success', '#main', (data) ->

  # REVIEW: Set up pjax with push: false, then push  the url manually here
  #  This removes the randomizer that is introduced for cache: false.
  window.history.pushState(null, null, data.relatedTarget.href.replace(/\?.*/, ''))

  content_initializers()
  content_initializers_reload_only()

$(window).on 'resize', ->
  resize_initializers()
