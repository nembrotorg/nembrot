toggle_code = () ->
  window.scrollTo(0, 0)
  $("#code").toggle('slide', { direction: 'right' }, 500)
  #$("#code").toggle()

  # This needs to run once per file (tab)
  # and only when it is visible
  # ga('send', 'pageview', file)

load_code = () ->
  #$('#html-source').html(document.documentElement.outerHTML)

  # Controller and action are written in <html>
  file = '/code/' + $('#main > div').attr('class').replace(/ .*/, '').replace('s-', '/').replace('-', '/')
  $.ajax
    url: file
    cache: true
    success: (html) ->
      $('#code').html(html)
      $("#tabs").tabs()
      html_code = document.documentElement.outerHTML
      html_code = hljs.highlight('html', html_code, true)
      html_code = hljs.fixMarkup(html_code.value)
      $('#htmlsource').html(html_code)

  # $.ajax
  #   url: "https://raw.githubusercontent.com/joegattnet/joegattnet_v3/master/app/models/note.rb"
  #   cache: true
  #   success: (code) ->
  #     code = hljs.highlight('ruby', code, true)
  #     code = hljs.fixMarkup(code.value)
  #     $('#htmlsource').html(code)

# Document hooks ******************************************************************************************************

$ ->
  load_code()

  $(document).on 'click', "a[href='#code'], a.close", ->
    toggle_code()
    false

  $(document).on 'pjax:success', '#main', (data) ->
    load_code()
