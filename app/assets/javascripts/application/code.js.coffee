toggle_code = () ->
  window.scrollTo(0, 0)
  #$("#code").toggle('slide', { }, 500)
  $("#code").toggle()

  # This needs to run once per file
  ga('send', 'pageview', file)

load_code = () ->
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

  $(document).on 'click', "a[href='#code']", ->
    toggle_code()
    false

$(document).on 'pjax:success', '#main', (data) ->
  load_code()
