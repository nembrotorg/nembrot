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

# Document hooks ******************************************************************************************************

$ ->
  load_code()

  $(document).on 'click', "a[href='#code'], a.close", ->
    toggle_code()
    false

  $(document).on 'pjax:success', '#main', (data) ->
    load_code()
