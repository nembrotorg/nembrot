DISQUS_API_KEY = 'qibvGX1OhK1EDIGCsc0QMLJ0sJHSIKVLLyCnwE3RZPKkoQ7Dj0Mm1oUS8mRjLHfq'
DISQUS_API_URL = 'https://disqus.com/api/3.0/threads/set.jsonp'

load_disqus_comments_count = () ->
  page_controller = $('html').data('controller')
  page_action = $('html').data('action')

  if (page_controller == 'notes' && page_action == 'show') || page_controller == 'features'
    $('.page').addClass('deep-link')
    $.getJSON DISQUS_API_URL + "?api_key=" + DISQUS_API_KEY + "&forum=" + window.Nembrot.DISQUS_SHORT_NAME + "&thread=" + encodeURIComponent(location.href), (data) ->
      count = _normalize_count(data.response.first)
    $('#tools a[href$="#comments"]').text(count)
  else
    $('.page').removeClass('deep-link')
    $('#tools a[href$="#comments"]').text('')

load_comments_count = () ->
  page_controller = $('html').data('controller')
  page_action = $('html').data('action')

  if (page_controller == 'notes' && page_action == 'show') || page_controller == 'features'
    $('.page').addClass('deep-link')
    count = RegExp(/\d+/).exec($('#comments h2').text())
    if count == null then count = ''
    $('#tools a[href$="#comments"]').text(count)
  else
    $('.page').removeClass('deep-link')
    $('#tools a[href$="#comments"]').text('')

window.Nembrot.load_comments_count = load_comments_count

# Document hooks ******************************************************************************************************

$ ->
  $(document).on 'submit', '#main section:not(#comments) form', (event) ->
    $.pjax.submit event, '[data-pjax-container]'
  
  # if $('#disqus_thread').length > 0 then load_disqus_comments_count(page_controller, page_action) # Check Settings first
  if $('#comments').length > 0 then load_comments_count()

  # if $('#disqus_thread').length > 0
  # DISQUS.reset
  #    reload: true
  #    config: ->
  #      @page.title = $('h1').text()
  #      @language = $('html').attr('lang')
  #      return

$(document).on 'pjax:success', '#main', (data) ->
  # if $('#disqus_thread').length > 0 then load_disqus_comments_count(page_controller, page_action) # Check Settings first
  if $('#comments').length > 0 then load_comments_count()
