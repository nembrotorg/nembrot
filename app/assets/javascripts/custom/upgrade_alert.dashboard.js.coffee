upgrade_alert = (message, category) ->
  $('#dashboard #upgrade_alert #message').html('<strong data-category="' + category + '">' + message + '</strong> Upgrade now to use shared notebooks, create unlimited websites with Premium themes, HD images, image effects, advanced settings and <a href="http://nembrot.com/premium" target="_blank">more</a>.')
  $('#dashboard #upgrade_alert').show('clip', 200)
  $('#dashboard input[type=submit]').attr('disabled','disabled')
  ga('send', 'event', 'Upgrade', 'alerted', category)

close_alert = () ->
  $('#dashboard #upgrade_alert').hide('clip', 100)
  $('#dashboard input[type=submit]').removeAttr('disabled')

premium_alert = (message, category) ->
  upgrade_alert message, category

business_alert = (message, category) ->
  upgrade_alert message, category

handle_notebook_selection = (element) ->
  clearTimeout(notebooks_timer)
  if element.data('shared') && !$('fieldset.notebooks').data('shared-notebooks')
    premium_alert 'You have chosen a shared notebook.', 'shared notebook'
  else if element.data('business') && !$('fieldset.notebooks').data('business-notebooks')
    business_alert 'You have chosen a business notebook.', 'business notebook'
  else if $('#dashboard .name input').val() == ''
    close_alert()
    notebooks_timer = setTimeout (->
      $('#dashboard .notebooks legend').addClass('completed')
      $('#dashboard form').accordion 'option', 'active', 2
      $('#dashboard .name input').focus()
    ), 500
  else
    close_alert()

handle_theme_selection = (element) ->
  if element.data('premium') && !$('fieldset.theme').data('premium-themes')
    premium_alert 'You have chosen a premium theme.', 'premium theme'
  else
    close_alert()

# Document hooks ******************************************************************************************************

$ ->
  # Alert if free user tries to create more than one site
  $(document).on 'click', '#dashboard a[href*="channels/new"].disabled, #dashboard li.deactivated a.disabled', (event) ->
    upgrade_alert 'You can have up to three websites.', 'extra website'
    event.preventDefault()

  # Automatically open name panel when a notebook is selected, if this is a new channel
  $(document).on 'focus', '#dashboard .notebooks input', (event) ->
    handle_notebook_selection($(event.target))

  # Can be DRYed up
  $(document).on 'blur', '#dashboard .notebooks select', (event) ->
    handle_notebook_selection($('#dashboard .notebooks select option:selected'))

  # Alert if free user chooses a premium theme
  $(document).on 'focus', '#dashboard .theme input', (event) ->
    handle_theme_selection($(event.target))

  # Can be DRYed up
  $(document).on 'blur', '#dashboard .theme select', (event) ->
    handle_theme_selection($('#dashboard .theme select option:selected'))
