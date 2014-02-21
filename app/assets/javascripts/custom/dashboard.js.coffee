load_dashboard = () ->
  $.ajax
    url: '/channels/choose/' + String($('[data-channel-slug]').data('channel-slug'))
    cache: false
    success: (html) ->
      $('#dashboard').html(html)

window.Nembrot.load_dashboard = load_dashboard

# Document hooks ******************************************************************************************************

$ ->
  $('#dashboard').draggable()

  $(document).pjax('#dashboard a:not(.show-channel)', '[data-pjax-dashboard]', { push: false } )
  $(document).pjax('#dashboard a.show-channel:not([data-remote])', '[data-pjax-container]')

  $(document).on 'submit', '#dashboard form', (event) ->
    $.pjax.submit event, '[data-pjax-dashboard]', { push: false }

  $(document).on 'keyup', (event) ->
    if event.keyCode == 27 && $('[data-theme-wrapper]').data('channel_slug') != 'default' then $('#dashboard').fadeOut() # REVIEW: Genericise

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

  if location.pathname == '/' && $('#dashboard').not(':visible')
    load_dashboard()
    $('#dashboard').show()

  thread = null
  $(document).on 'keyup', '#dashboard form .name input', (event) ->
    clearTimeout thread
    target = $(this)
    query_string = target.val()
    unless query_string is ""
      thread = setTimeout(->
        $.ajax
          url: "/channels/available/" + query_string
          cache: false
          success: (html) ->
            $("#dashboard .available").html html

        return
      , 500)
    return
