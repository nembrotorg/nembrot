change_theme = (theme) ->
  load_typekit_font(window.Nembrot.THEMES[theme]['typekit_code'])
  $('html, [data-theme]').alterClass('theme-*', 'theme-' + theme)
  $('html, [data-theme]').alterClass('*-module', window.Nembrot.THEMES[theme]['css'])
  $('html').data('controller', $('body [data-controller]').data('controller'))
  $('html').data('action', $('body [data-action]').data('action'))

  window.Nembrot.load_maps(theme)
  window.Nembrot.add_thumbnails()
  change_image_effects(theme)

change_theme_if_editing_channel = (theme) ->
  if String($('[data-channel-id]').data('channel-id')) == String($('#dashboard .channels-edit #channel_id').val()) then change_theme(theme)

change_image_effects = (theme) ->
  $("figure.image img").each ->
    $(this).attr 'src', $(this).attr('src').replace(/^(.*\-)([^\-]*?)(\-\d{1,9}\.)(gif|jpeg|png)$/, '$1' + window.Nembrot.THEMES[theme]['effects'] + '$3$4')

load_typekit_font = (code) ->
  $.cachedScript('//use.typekit.net/' + code + '.js').done (script) ->
    try
      Typekit.load()

window.Nembrot.load_typekit_font = load_typekit_font

# Document hooks ******************************************************************************************************

$ ->
  change_theme($('[data-theme]').data('theme'))

  $(window).on 'popstate', ->
    change_theme($('[data-theme]').data('theme'))

  $(document).on 'pjax:success', '#main', (data) ->
    change_theme($('[data-theme]').data('theme'))

  $(document).on 'change', '#dashboard input[name="channel[theme_id]"]', ->
    change_theme_if_editing_channel($(@).data('slug'))
