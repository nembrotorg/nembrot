/*

buttons = $("input[type=radio]")
arrays = _.groupBy(buttons, (button) ->
  button.name
)

#console.log(arrays);
_.each arrays, (element, index, list) ->
  
  # console.log(element, index, list);
  new_select = $("<select></select>")
  new_select.attr "name", $(element).attr("name")
  _.each element, (element, index, list) ->
    
    #console.log(element.value);
    new_option = $("<option></option>")
    new_option.attr "value", element.value
    new_option.text $("label[for=" + element.id + "]").text()
    $(new_select).append new_option
    return

  $(element).closest("div").append new_select
  return

*/
