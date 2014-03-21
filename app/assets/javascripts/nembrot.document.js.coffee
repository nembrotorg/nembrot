window.Nembrot ?= {}
jQuery.fn.reverse = [].reverse

update_titles = () ->
  title_data = $('#main header:first-of-type').data('title')
  if title_data
    document.title = title_data

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

load_share_links = (page_class) ->
  if page_class.indexOf('-show') != -1
    $('.share').addClass('deep-link')
    title = $('h1').text().trim()
    url = encodeURIComponent(location.href)
  else
    $('.share').removeClass('deep-link')
    title = 'joegatt.net'
    url = 'http://' + encodeURIComponent(location.host)

  facebook_link = $('li.share a[href*=facebook]')
  twitter_link = $('li.share a[href*=twitter]')
  googleplus_link = $('li.share a[href*=google]')

  facebook_link.attr('href', 'http://www.facebook.com/share.php?u=' + url + '&title=' + title)
  twitter_link.attr('href', 'http://twitter.com/home?status=' + title + '+' + url)
  googleplus_link.attr('href', 'https://plus.google.com/share?url=' + url)

  $.getJSON FACEBOOK_API_URL + url, (data) ->
    count = _normalize_count(data.shares)
    facebook_link.text(shorter_total(count))

  $.getJSON TWITTER_API_URL + "?callback=?&url=" + url, (data) ->
    count = _normalize_count(data.count)
    twitter_link.text(shorter_total(count))

  # Get googleplus: https://gist.github.com/jonathanmoore/2640302

DISQUS_API_KEY = 'qibvGX1OhK1EDIGCsc0QMLJ0sJHSIKVLLyCnwE3RZPKkoQ7Dj0Mm1oUS8mRjLHfq'
DISQUS_API_URL = 'https://disqus.com/api/3.0/threads/set.jsonp'

load_disqus_comments_count = (page_class) ->
  if page_class.indexOf('notes-show') != -1 || page_class.indexOf('features-') != -1
    $('.page').addClass('deep-link')
    $.getJSON DISQUS_API_URL + "?api_key=" + DISQUS_API_KEY + "&forum=" + DISQUS_SHORT_NAME + "&thread=" + encodeURIComponent(location.href), (data) ->
      count = _normalize_count(data.response.first)
    $('#tools a[href$="#comments"]').text(count)
  else
    $('.page').removeClass('deep-link')
    $('#tools a[href$="#comments"]').text('')

load_comments_count = (page_class) ->
  if page_class.indexOf('notes-show') != -1 || page_class.indexOf('features-') != -1
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
  $('footer img.qr_code').remove()
  $('footer').prepend('<img class="qr_code" src="https://chart.googleapis.com/chart?chs=150x150&cht=qr&chl=' + location.href + '" alt="QR code">')

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

toggle_code = () ->
  #$("#code").toggle('slide', { }, 500)
  $("#code").toggle()

load_code = () ->
  file = '/code/' + $('#main > div').attr('class').replace('s-', '/')
  $.ajax
    url: file
    cache: true
    success: (html) ->
      $('#code').html(html)
      ga('send', 'pageview', file)

# Document hooks ******************************************************************************************************

$ ->
  document_initializers()

$(document).on 'pjax:end', '[data-pjax-container]', ->
  content_initializers()
  content_initializers_reload_only()

$(window).on 'resize', ->
  resize_initializers()

# Initializers ********************************************************************************************************

document_initializers = () ->
  # Implementing a spinner may be a better idea: https://github.com/defunkt/jquery-pjax/issues/129
  $.pjax.defaults.timeout = false
  $(document).pjax('#main a, #tools a, footer a', '[data-pjax-container]')

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

  $(document).on 'click', "a[href='#code']", ->
    toggle_code()
    false

  $(document).on 'touchmove', 'body', ->
    add_scrolling_class()

  $(window).scroll ->
    add_scrolling_class()

  $(window).mousemove ->
    clearTimeout(window.mousemoving)
    $('body').addClass('mousemoving')
    window.mousemoving = setTimeout(->
      $('body').removeClass('mousemoving')
    , 3000)

  load_user_menu()

  content_initializers()

content_initializers = () ->
  $('time').timeago()
  update_titles()
  track_page_view()
  resize_initializers()
  insert_qr_code()
  load_code()

  page_class = $('#main > div').attr('class')
  load_share_links(page_class)
  if $('#disqus_thread').length > 0 then load_disqus_comments_count(page_class) # Check Settings first
  if $('#comments').length > 0 then load_comments_count(page_class)

window.Nembrot.content_initializers = content_initializers

content_initializers_reload_only = () ->

resize_initializers = () ->
  place_annotations()
