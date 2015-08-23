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
  $('body > footer').append('<img onload="$(document).trigger(\'nembrot:painted\')" class="qr_code" src="https://chart.googleapis.com/chart?chs=150x150&cht=qr&rnd=' + Math.random() + '&chl=' + location.href + '" alt="QR code">')

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
  $('.links li a p, .citations li a blockquote').dotdotdot({
    tolerance: 5,
    watch: true
  })

build_tabs = () ->
  $("#tabs").tabs()

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

mini_scrollbar = (elements) ->
  $(elements).slimScroll
    height: 'auto'
    size: '10px'
    position: 'right'
    color: '#999'
    alwaysVisible: false
    distance: '0'
    start: $('#child_image_element')
    railVisible: true
    railColor: '#ccc'
    railOpacity: 0.5
    wheelStep: 10
    allowPageScroll: true
    disableFadeOut: true

window.Nembrot.mini_scrollbar = mini_scrollbar

$ ->
  # Implementing a spinner may be a better idea: https://github.com/defunkt/jquery-pjax/issues/129
  $(document).on 'pjax:timeout', 'body', ->
    false

  $(document).pjax('#main a:not([data-remote]),footer a', '[data-pjax-container]')

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

  $(document).on 'click', 'a[href="#close"]', (event) ->
    event.preventDefault()
    parent = $(event.target).parent()
    parent.fadeOut()
    $('html').removeClass(parent.attr('id') + '-open')

  $('time').timeago()
  update_titles()
  load_user_menu()
  truncate_blurbs()
  hljs.initHighlightingOnLoad()
  build_tabs()
  insert_qr_code()
  Hyphenator.run()

  # REVIEW: This isn't working at the moment
  #  There's a hardcoded script at the end of form.
  #  Also we need to open .active
  # $('#dashboard form').accordion header: 'legend'

  $(window).on 'resize', ->
    window.Nembrot.place_annotations()

$(document).on 'nembrot:hyphenated', ->
  unorphan($('p, blockquote, #annotations li, #comments li'))
  window.Nembrot.fix_collated_paragraph_heights()
  window.Nembrot.place_annotations()

$(document).on 'pjax:success', '#main', (data) ->
  $('time').timeago()
  update_titles()
  truncate_blurbs()
  hljs.initHighlightingOnLoad()
  build_tabs()
  insert_qr_code()
  Hyphenator.run()

#$ ->
  #$(window).on 'resize', ->
  #  truncate_blurbs()
  # Document hooks ******************************************************************************************************

  #$(document).on 'painted', ->
  #  place_annotations()

  #$(document).on 'pjax:success', '#main', (data) ->
  #  place_annotations()

  #$(window).on 'popstate', ->
  #  place_annotations()
