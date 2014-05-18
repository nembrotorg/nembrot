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
