# get these from gon (gon.typekit_codes)
TYPEKITS =
  nembrot: 'crv1apl'
  dark: 'crv1apl'
  leipzig: 'qho7ezg'
  maps: 'crv1apl'
  meta: 'crv1apl'
  home: 'srt1pbp'
  magazine: 'jix2vil'

change_theme = (theme) ->
  load_typekit_font(TYPEKITS[theme])
  $('html, [data-theme]').alterClass('theme-*', 'theme-' + theme)

change_theme_if_editing_channel = (theme) ->
  if String($('[data-channel-id]').data('channel-id')) == String($('#dashboard .channels-edit input[name=id]').val()) then change_theme(theme)

load_typekit_font = (name) ->
  $.cachedScript('//use.typekit.net/' + name + '.js').done (script) ->
    try
      Typekit.load()

window.Nembrot.load_typekit_font = load_typekit_font

# Document hooks ******************************************************************************************************

$ ->
  $(document).on 'pjax:success', '#main', (data) ->
    change_theme($('[data-theme]').data('theme'))

  $(document).on 'change', '#dashboard input[name="channel[theme]"]', ->
    change_theme_if_editing_channel(@value)
