load_dashboard = () ->
  $.ajax
    url: '/channels/choose/' + String($('[data-channel-slug]').data('channel-slug'))
    cache: false
    success: (html) ->
      $('#dashboard').html(html)

auto_open_dashboard = () ->
  if location.pathname == '/' && $('#dashboard').not(':visible')
    load_dashboard()
    $('#dashboard').show()

# Document hooks ******************************************************************************************************

$ ->
  dashboard_button = $('#tools a[href*=channels]')

  $('html:not(.theme-home-2) #dashboard').draggable() # FIXME: Coupled with theme (& uses different method from esc/keyup)

  $(document).pjax('#dashboard a:not(.show-channel)', '[data-pjax-dashboard]', { push: false } )
  $(document).pjax('#dashboard a.show-channel:not([data-remote])', '[data-pjax-container]')

  $(document).on 'submit', '#dashboard form', (event) ->
    $.pjax.submit event, '[data-pjax-dashboard]', { push: false }

  # REVIEW: Access current channel data more efficiently (read data once)
  $(document).on 'keyup', (event) ->
    if event.keyCode == 27 && $('[data-theme-wrapper]').data('channel-slug') != 'default'
      $('#dashboard').fadeOut() # REVIEW: Genericise
      dashboard_button.fadeIn()

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
    # Test if it's hidden rather than test if it's visible later so that dashboard can load
    #  while the dashboard is fading in 
    if $('#dashboard').is(':hidden')
      load_dashboard()
      dashboard_button.fadeOut()
    $('#dashboard').fadeToggle()

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

  # This was genericised but we still needed to deal with the button
  #  a less coupled callback on the dashboard's visibility my solve it.
  #  Maybe fire an event 'clofing' on the parent.
  $(document).on 'click', 'a[href="#close"]', (event) ->
    event.preventDefault()
    $(event.target).parent().fadeOut()
    dashboard_button.fadeIn()

$(document).on 'pjax:success', '#main', (data) ->
  $('html:not(.theme-home-2) #dashboard').draggable() # FIXME: Coupled with theme
  auto_open_dashboard()

$(window).on 'popstate', ->
  auto_open_dashboard()
