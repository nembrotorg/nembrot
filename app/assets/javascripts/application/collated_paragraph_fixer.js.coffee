fix_collated_paragraph_heights = ->
  $('.collate .body > div').each ->
    source = $(this).find('p.source')
    target = $(this).find('p.target')
    counter = 0
    shorten = true
    while (source.outerHeight(false) isnt target.outerHeight(false)) && counter < 100
      if counter == 0
        source.css 'word-spacing': '0px'
        target.css 'word-spacing': '0px'
        source.css 'letter-spacing': '0px'
        target.css 'letter-spacing': '0px'
      shorter = (if source.outerHeight(false) < target.outerHeight(false) then source else target)
      longer = (if source.outerHeight(false) > target.outerHeight(false) then source else target)
      if shorten
        longer.css 'word-spacing': '-=0.1'
        longer.css 'letter-spacing': '-=0.0.05'
      else
        shorter.css 'word-spacing': '+=0.1'
        shorter.css 'letter-spacing': '+=0.05'
      counter = counter + 1
      shorten = !shorten

    return

window.Nembrot.fix_collated_paragraph_heights = fix_collated_paragraph_heights
