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

add_scrolling_class = () ->
  clearTimeout(window.scrolling)
  $('body').addClass('scrolling')
  window.scrolling = setTimeout(->
    $('body').removeClass('scrolling')
  , 3000)

insert_qr_code = () ->
  # Get image size from settings
  $('body > footer img.qr_code').remove()
  $('body > footer').prepend('<img class="qr_code" src="https://chart.googleapis.com/chart?chs=150x150&cht=qr&chl=' + location.href + '" alt="QR code">')

load_user_menu = () ->
  $.ajax
    url: '/users/menu'
    cache: false
    success: (html) ->
      $('#tools .user').html(html)

update_titles = () ->
  title_data = $('#main header:first-of-type').data('title')
  if title_data
    document.title = title_data

truncate_blurbs = () ->
  $('.notes li a, .channels li a').dotdotdot()

_normalize_count = (data) ->
    count = ''
    count = data
    if count == 0 then count = ''
    count

_shorter_total = (num) ->
  if num >= 1e6
    num = (num / 1e6).toFixed(2) + "M"
  else if num >= 1e3
    num = (num / 1e3).toFixed(1) + "k"
  num

window.Nembrot.load_user_menu = load_user_menu

# Document hooks ******************************************************************************************************

$ ->
  # Implementing a spinner may be a better idea: https://github.com/defunkt/jquery-pjax/issues/129
  $.pjax.defaults.timeout = false
  $(document).pjax('#main a:not([data-remote]), .persistent_map a:not([data-remote])', '[data-pjax-container]')

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

  clearTimeout(window.documentloading)
  window.documentloading = setTimeout(->
    $('html').removeClass('document-loading')
  , 3000)

  $(document).on 'click', 'a[href="#close"]', (event) ->
    event.preventDefault()
    $(event.target).parent().fadeOut()

  $('time').timeago()
  update_titles()
  truncate_blurbs()
  insert_qr_code()
  load_user_menu()

  # REVIEW: This isn't working at the moment
  #  There's a hardcoded script at the end of form.
  #  Also we need to open .active
  # $('#dashboard form').accordion header: 'legend'

$(document).on 'pjax:success', '#main', (data) ->
  $('time').timeago()
  update_titles()
  truncate_blurbs()
  insert_qr_code()

  # if $('#disqus_thread').length > 0 then load_disqus_comments_count(page_controller, page_action) # Check Settings first
  if $('#comments').length > 0 then load_comments_count(page_controller, page_action)
