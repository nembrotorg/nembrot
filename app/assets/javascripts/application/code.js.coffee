toggle_code = () ->
  window.scrollTo(0, 0)
  #$("#code").toggle('slide', { }, 500)
  $("#code").toggle()

load_code = () ->
  file = '/code/' + $('#main > div').attr('class').replace(/ .*/, '').replace('s-', '/').replace('-', '/')
  $.ajax
    url: file
    cache: true
    success: (html) ->
      $('#code').html(html)
      ga('send', 'pageview', file)
      $("#tabs").tabs()

# Document hooks ******************************************************************************************************

$ ->
  $(document).on 'click', "a[href='#code']", ->
    toggle_code()
    false

  load_code()

  $(document).on 'pjax:success', '#main', (data) ->
    load_code()
