# Convert lists of radio buttons to dropdown menus on touch devices

transform_radio_buttons_to_select = () ->

  # Discover groups of radio buttons
  buttons = $('html:not(.wider-than-720px) input[type=radio]:not(.transformed-to-select)')
  arrays = _.groupBy(buttons, (button) ->
    button.name
  )

  # Create a dropdown menu for each group
  _.each arrays, (element, index, list) ->
    new_select = $('<select></select>')
    new_select.attr 'name', $(element).attr('name')
    new_select.addClass('transformed-from-radio-buttons')
    _.each element, (element, index, list) ->
      new_option = $('<option></option>')
      new_option.attr 'value', element.value
      new_option.text $('label[for=' + element.id + ']').text()
      if $(element).attr('checked') then new_option.attr 'selected', true

      if $(element).data('premium') then new_option.attr 'data-premium',true
      if $(element).data('business') then new_option.attr 'data-business', true
      if $(element).data('shared') then new_option.attr 'data-shared', true

      if $(element).data('premium') then new_option.text new_option.text() + ' (Premium)'
      if $(element).data('business') then new_option.text new_option.text() + ' (Business)'
      if $(element).data('shared') then new_option.text new_option.text() + ' (Shared)'

      $(new_select).append new_option
      $(element).closest('label').addClass('transformed-to-select')
      $(element).addClass('transformed-to-select')
      $(element).attr('disabled', true)
      return

    $(element).closest('div').append new_select
    return

window.Nembrot.transform_radio_buttons_to_select = transform_radio_buttons_to_select
