# These functions try to solve the problem of cached pages when a user is editing their channel
#  It also involved setting up all pjax clicks with push: false, then push the url manually here
#  This removes the randomizer that is introduced for cache: false.
#  But it also breaks the browser buttons.
# window.history.pushState(null, null, data.relatedTarget.href.replace(/\?.*/, ''))

# window.Nembrot.my_channels = []

# mark_as_mine = () ->
#   $('a').removeClass('mine')
#   $.each window.Nembrot.my_channels, (i, e) ->
#     $('a[href^="/' + e + '"]').addClass('mine')

# Document hooks ******************************************************************************************************

# $ ->
#   $(document).pjax('#main a.mine', '[data-pjax-container]', { cache: false, push: false })
#   mark_as_mine()

# $(document).on 'pjax:success', '#main', (data) ->
#   mark_as_mine()
