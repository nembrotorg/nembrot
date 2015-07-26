prepare_modal = () ->
  $("#tabs").tabs()
  load_source()

load_source = () ->
  code = document.documentElement.outerHTML
  code = hljs.highlight('html', code, true)
  code = hljs.fixMarkup(code.value)
  $('#source pre code').html(code)

open_modal = () ->
  $("#code").show('slide', { direction: 'right' }, 500)
  load_code()
  # ga('send', 'pageview', file)

close_modal = () ->
  $("#code").hide('slide', { direction: 'right' }, 500)

load_code = () ->
  current_controller_and_action = $('#main > div').attr('class')
  [controller, action] = current_controller_and_action.split('-')
  controller = normalize_controller(controller)
  model =  normalize_model(controller)
  action = normalize_action(action)

  unless $('#view-code').data('loaded') == current_controller_and_action
    file = "app/views/#{ controller }/#{ action }.html.slim"
    # This should be Slim - but it's not available
    fetch_and_show_code(file, 'coffeescript', 'view', current_controller_and_action)

  unless $('#controller-code').data('loaded') == current_controller_and_action
    file = "app/controllers/#{ controller }_controller.rb"
    fetch_and_show_code(file, 'ruby', 'controller', current_controller_and_action)

  unless $('#model-code').data('loaded') == current_controller_and_action
    file = "app/models/#{ model }.rb"
    fetch_and_show_code(file, 'ruby', 'model', current_controller_and_action)

singularize = (word) ->
  word.replace(/s$/, '')

pluralize = (word) ->
  "#{word}s".replace(/ss$/, 's')

normalize_model = (word) ->
  singularize(word)
  word.replace(/(colophon|home)/, 'note')
  word

normalize_controller = (word) ->
  word.replace(/(features|citations|links)/, 'notes')
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

fetch_and_show_code = (file, language, div, current_controller_and_action) ->
  $.ajax
    url: "https://raw.githubusercontent.com/joegattnet/joegattnet_v3/master/#{file}"
    cache: true
    success: (code) ->
      code = decorate_code(code, language)
      $("##{ div } h2").html("#{file}")
      $("##{ div } pre code").html(code)
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

  $(document).on 'keyup', (event) ->
    if event.keyCode == 27
      close_modal()

  $(document).on 'pjax:success', '#main', (data) ->
    load_code()
