load_dashboard = () ->
  $.ajax
    url: '/channels/choose/' + String($('[data-channel-slug]').data('channel-slug'))
    cache: false
    success: (html) ->
      $('#dashboard').html(html)

auto_open_dashboard = () ->
  if $('html:not(.theme-home) #dashboard').not(':visible')
    load_dashboard()
    if $('#dashboard').draggable() then $('#dashboard').draggable('destroy')
    $('#dashboard').show()
  else
    $('html:not(.theme-home) #dashboard').draggable() # FIXME: Coupled with theme

position_dashboard = () ->
  $('html.wider-than-720px.theme-home #dashboard').css('top', '').css('bottom', '')
  $('html.theme-home:not(.wider-than-720px) #dashboard').css('top', parseInt($('#content').offset().top + $('#content').outerHeight(true)) + 'px').css('bottom', '')

# Document hooks ******************************************************************************************************

$ ->
  $(document).pjax('#dashboard a:not(.show-channel)', '[data-pjax-dashboard]', { push: false } )
  $(document).pjax('#dashboard a.show-channel:not([data-remote])', '[data-pjax-container]')

  $(document).on 'submit', '#dashboard form', (event) ->
    $.pjax.submit event, '[data-pjax-dashboard]', { push: false }

  # REVIEW: Access current channel data more efficiently (read data once)
  $(document).on 'keyup', (event) ->
    if event.keyCode == 27 && $('[data-theme-wrapper]').data('channel-slug') != 'default' then $('#dashboard').fadeOut() # REVIEW: Genericise

  # Automatically open name panel when a notebook is selected, if this is a new channel
  $(document).on 'click', '#dashboard .notebooks label', ->
    if $('#dashboard .name input').val() == ''
      setTimeout (->
        $('#dashboard .notebooks legend').addClass('completed')
        $('#dashboard form').accordion 'option', 'active', 2
        $('#dashboard .name input').focus()
      ), 500

  $(document).on 'click', '#tools a[href*=channels]', (event) ->
    event.preventDefault()
    $('#dashboard').fadeToggle()
    if $('#dashboard').is(':visible') then load_dashboard()

  position_dashboard()
  auto_open_dashboard()

  thread = null
  $(document).on 'keyup', '#dashboard form .name input', (event) ->
    clearTimeout thread
    target = $(this)
    query_string = target.val()
    unless query_string is ''
      thread = setTimeout(->
        $.ajax
          url: "/channels/available/" + query_string
          cache: false
          success: (html) ->
            $("#dashboard .available").html html
        return
      , 500)
    return

  $(document).on 'pjax:success', '#main', (data) ->
    position_dashboard()
    auto_open_dashboard()

  $(window).on 'popstate', ->
    position_dashboard()
    auto_open_dashboard()

  $(window).on 'resize', ->
    position_dashboard()
    auto_open_dashboard()
