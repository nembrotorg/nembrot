jQuery.fn.reverse = [].reverse

update_titles = () ->
  title_data = $('#main header:first-of-type').data('title')
  if title_data
    document.title = title_data

track_page_view = () ->
  _gaq = window._gaq ?= []
  _gaq.push(['_trackPageview', location.pathname])

track_outbound_link = (link, category, action) ->
  try
    _gaq.push ['_trackEvent', category, action, link]

  setTimeout (->
    document.location.href = link
  ), 100

track_download = (link, category, action, which) ->
  try
    _gaq.push ['_trackEvent', category, action, link, which]

place_annotations = () ->
  if $('.annotations').length
    (if _media_query('default') then _place_annotations_undo() else _place_annotations_do())
    $('#text').addClass('fadeable-annotations')
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

  maximum = $('#text').offset().top + $('#text').outerHeight(false)
  annotations.reverse().each () ->
    if $(this).offset().top + $(this).outerHeight(true) >= maximum 
      maximum = $(this).offset().top - $(this).outerHeight(true)
      $(this).offset top: maximum

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
# https://graph.facebook.com/fql?q=SELECT%20url,%20normalized_url,%20share_count,%20like_count,%20comment_count,%20total_count,commentsbox_count,%20comments_fbid,%20click_count%20FROM%20link_stat%20WHERE%20url=%27{url}%27&callback=?"
# _gaq.push(['_trackSocial', 'facebook', 'like', targetUrl]);
# _gaq.push(['_trackSocial', 'twitter', 'tweet']);

FACEBOOK_API_URL = 'http://graph.facebook.com/'
TWITTER_API_URL = "http://cdn.api.twitter.com/1/urls/count.json"

load_share_links = () ->
  page_class = $('#main > div').attr('class')

  if page_class.indexOf('-show') > 0
    $('.share').addClass('deep-link')
    title = $('h1').text().trim()
    url = encodeURIComponent(location.href)
  else
    $('.share').removeClass('deep-link')
    title = 'nembrot.org'
    url = 'http://' + encodeURIComponent(location.host)

  console.log(url)

  facebook_link = $('li.share a[href*=facebook]')
  twitter_link = $('li.share a[href*=twitter]')
  googleplus_link = $('li.share a[href*=google]')

  facebook_link.attr('href', 'http://www.facebook.com/share.php?u=' + url + '&title=' + title)
  twitter_link.attr('href', 'http://twitter.com/home?status=' + title + '+' + url)
  googleplus_link.attr('href', 'https://plus.google.com/share?url=' + url)

  $.getJSON FACEBOOK_API_URL + url, (data) ->
    count = _normalize_share_count(data.shares)
    facebook_link.text(shorter_total(count))

  $.getJSON TWITTER_API_URL + "?callback=?&url=" + url, (data) ->
    count = _normalize_share_count(data.count)
    twitter_link.text(shorter_total(count))

  # Get googleplus: https://gist.github.com/jonathanmoore/2640302

_normalize_share_count = (data) ->
    count = ''
    count = data
    if count == 0 then count = ''
    console.log(count)
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

# Document hooks ******************************************************************************************************

$ ->
  document_initializers()

$(document).on 'pjax:end', ->
  content_initializers()
  content_initializers_reload_only()

$(window).on 'resize', ->
  resize_initializers()

# Initializers ********************************************************************************************************

document_initializers = () ->
  # Implementing a spinner may be a better idea: https://github.com/defunkt/jquery-pjax/issues/129
  $.pjax.defaults.timeout = false
  $(document).pjax('a:not([data-remote]):not([data-behavior]):not([data-skip-pjax])', '[data-pjax-container]')

  $(document).on 'click', 'a[href^=http]', ->
    track_outbound_link(this.href, 'Outbound Link', this.href.toString().replace(/^https?:\/\/([^\/?#]*).*$/, '$1'))
    false

  $(document).on 'mousedown', "a[href$='.pdf'], a[href$='.zip']", (event) ->
    track_download(this.href.toString().replace(/^https?:\/\/([^\/?#]*)(.*$)/, '$2'), 'Download', this.text, event.which)

  $(document).on 'click', '.fb-like', ->
    fix_facebook_dialog()

  content_initializers()

content_initializers = () ->
  $('time').timeago()
  update_titles()
  track_page_view()
  resize_initializers()
  insert_qr_code()
  load_share_links()

content_initializers_reload_only = () ->

resize_initializers = () ->
  place_annotations()
