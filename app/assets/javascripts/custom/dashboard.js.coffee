load_dashboard = () ->
  $.ajax
    url: '/channels/choose/' + String($('[data-channel-slug]').data('channel-slug'))
    cache: false
    success: (html) ->
      $('#dashboard').html(html)

auto_open_dashboard = () ->
  if $('.theme-home').size() > 0
    load_dashboard()
    if $('#dashboard').draggable() then $('#dashboard').draggable('destroy')
    $('#dashboard').show()
    $('html').addClass('dashboard-open')
  else
    $('#dashboard').draggable()

upgrade_alert = (message) ->
  $('#dashboard #upgrade_alert #message').html('<strong>' + message + '</strong> Upgrade now to use shared notebooks, create unlimited websites with Premium themes, HD images, image effects, advanced settings and <a href="http://nembrot.com/premium" target="_blank">more</a>.')
  $('#dashboard #upgrade_alert').show('clip', 200)
  $('#dashboard input[type=submit]').attr('disabled','disabled')

close_alert = () ->
  $('#dashboard #upgrade_alert').hide('clip', 100)
  $('#dashboard input[type=submit]').removeAttr('disabled')

premium_alert = (message) ->
  upgrade_alert message

business_alert = (message) ->
  upgrade_alert message

# Document hooks ******************************************************************************************************

$ ->
  $(document).pjax('#dashboard a:not(.show-channel):not(.disabled)', '[data-pjax-dashboard]', { push: false } )
  $(document).pjax('#dashboard a.show-channel:not([data-remote])', '[data-pjax-container]')

  $(document).on 'submit', '#dashboard form', (event) ->
    $.pjax.submit event, '[data-pjax-dashboard]', { push: false }

  # REVIEW: Access current channel data more efficiently (read data once)
  $(document).on 'keyup', (event) ->
    if event.keyCode == 27 && $('[data-theme-wrapper]').data('channel-slug') != 'default'
      $('#dashboard').fadeOut() # REVIEW: Genericise
      $('html').removeClass('dashboard-open')

  # Alert if free user tries to create more than one site
  $(document).on 'click', '#dashboard a[href*="channels/new"].disabled', (event) ->
    upgrade_alert 'You can create up to three websites.'
    event.preventDefault()

  # Automatically open name panel when a notebook is selected, if this is a new channel
  $(document).on 'focus', '#dashboard .notebooks input', (event) ->
    clearTimeout(notebooks_timer)
    if $(event.target).data('shared') && !$('fieldset.notebooks').data('shared-notebooks')
      premium_alert 'You have chosen a shared notebook.'
    else if $(event.target).data('business') && !$('fieldset.notebooks').data('business-notebooks')
      business_alert 'You have chosen a business notebook.'
    else if $('#dashboard .name input').val() == ''
      close_alert()
      notebooks_timer = setTimeout (->
        $('#dashboard .notebooks legend').addClass('completed')
        $('#dashboard form').accordion 'option', 'active', 2
        $('#dashboard .name input').focus()
      ), 500
    else
      close_alert()

  # Alert if free user chooses a premium theme
  $(document).on 'focus', '#dashboard .theme input', (event) ->
    if $(event.target).data('premium') && !$('fieldset.theme').data('premium-themes')
      premium_alert('You have chosen a premium theme.')
    else
      close_alert()

  $(document).on 'click', '#tools a[href*=channels]', (event) ->
    event.preventDefault()
    fading_in = $('#dashboard').is(':hidden')
    $('#dashboard').fadeToggle()
    if fading_in
      load_dashboard()
      $('html').addClass('dashboard-open')
    else
      $('html').removeClass('dashboard-open')

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
    auto_open_dashboard()

  $(window).on 'popstate', ->
    auto_open_dashboard()

  $(window).on 'resize', ->
    auto_open_dashboard()
