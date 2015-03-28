load_share_links_in_iframes = () ->
  FB.XFBML.parse()
  gapi.plusone.go()
  twttr.widgets.load()

# From Sharrre plug-in https://raw.github.com/Julienh/Sharrre/master/jquery.sharrre.js
# https://graph.facebook.com/fql?q=SELECT%20url,%20normalized_url,%20share_count,%20like_count,%20comment_count,%20tot
#  al_count,commentsbox_count,%20comments_fbid,%20click_count%20FROM%20link_stat%20WHERE%20url=%27{url}%27&callback=?"

FACEBOOK_API_URL = 'http://graph.facebook.com/'
TWITTER_API_URL = "http://cdn.api.twitter.com/1/urls/count.json"

load_share_links = (page_controller, page_action) ->
  if page_action == 'show'
    $('.share').addClass('deep-link')
    title = $('h1').text().trim()
    url = encodeURIComponent(location.href)
  else
    $('.share').removeClass('deep-link')
    title = 'joegatt.net'
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
    facebook_count = _shorter_total(facebook_count)
    facebook_count

get_twitter_count = (url) ->
  $.getJSON TWITTER_API_URL + "?callback=?&url=" + url, (data) ->
    twitter_count = _normalize_count(data.count)
    twitter_count = _shorter_total(twitter_count)
    twitter_count

fix_facebook_dialog = () ->
  $('.fb-like span').css('width', $('.fb-like').data('width'))

# Document hooks ******************************************************************************************************

$ ->
  $(document).on 'click', '.fb-like', ->
    page_controller = $('html').data('controller')
    page_action = $('html').data('action')
    fix_facebook_dialog()
    load_share_links(page_controller, page_action)

  $(document).on 'pjax:success', '#main', (data) ->
    page_controller = $('html').data('controller')
    page_action = $('html').data('action')
    load_share_links(page_controller, page_action)
