prepare_modal = () ->
  $("#tabs").tabs()
  load_source()

load_source = () ->
  html_code = document.documentElement.outerHTML
  html_code = hljs.highlight('html', html_code, true)
  html_code = hljs.fixMarkup(html_code.value)
  $('#html-source').html(html_code)

open_modal = () ->
  $("#code").show('slide', { direction: 'right' }, 500)
  #$("#code").toggle('slide', { direction: 'left' }, 500)
  # ga('send', 'pageview', file)

close_modal = () ->
  $("#code").hide('slide', { direction: 'right' }, 500)
  #$("#code").toggle('slide', { direction: 'left' }, 500)

load_code = () ->
  current_controller_and_action = $('#main > div').attr('class')
  [controller, action] = current_controller_and_action.split('-')
  controller = normalize_controller(controller)
  action = normalize_action(action)

  unless $('#view-code').data('loaded') == current_controller_and_action
    show_code("#{ pluralize(controller) }/#{ action }.html.slim", 'slim', '#view-code', current_controller_and_action)

  unless $('#controller-code').data('loaded') == current_controller_and_action
    show_code("#{ controller(controller) }_controller.rb", 'ruby', '#controller-code', current_controller_and_action)

  unless $('#model-code').data('loaded') == current_controller_and_action
    show_code("#{ singularize(controller) }.rb", 'ruby', '#model-code', current_controller_and_action)

singularize = (word) ->
  word.replace(/s$/, '')

pluralize = (word) ->
  "#{word}s".replace(/ss$/, 's')

normalize_controller = (word) ->
  word.replace(/(feature|citation|link)/, 'notes')
  word

normalize_action = (word, controller) ->
  if controller == 'pantography'
    word = 'show'
  else
    word.replace(/.*show/, 'show')
  word

decorate_code = (code, language) ->
  code = hljs.highlight(language, code, true)
  code = hljs.fixMarkup(code.value)

fetch_from_github = (file, language, div, current_controller_and_action) ->
  $.ajax
    url: "https://raw.githubusercontent.com/joegattnet/joegattnet_v3/master/app/#{file}"
    cache: true
    success: (code) ->
      code = decorate_code(code, language)
      $(div).html(code)
      $(div).data('loaded', current_controller_and_action)

# Document hooks ******************************************************************************************************

$ ->
  prepare_modal()

  $(document).on 'click', "a[href='#code']", ->
    open_modal()
    false

  $(document).on 'click', "a.close", ->
    close_modal()
    false

  $(document).on 'pjax:success', '#main', (data) ->
    load_code()
