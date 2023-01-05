# If the barcode label is scanned into the list search field in the acceptance
# then the value will have the structure
#   EVENTID|LISTNR|ITEMNR|CHECKDIGIT
# What the list search field expects is the list number (LISTNR) only.
jQuery ->
  # Check whether the barcode has been entered with a CR
  $('#search_acceptance_list_number').keydown (e) ->
    if e.keyCode == 13
      extract_list_number_to_field($(this))

  # Check whether the barcode has been entered with a Button click
  $('#button_search_acceptance_list_number').click ->
    extract_list_number_to_field($('#search_acceptance_list_number'))

# Extract the list number out of the string and write the list number into the
# list search field
extract_list_number_to_field = (field) ->
  value = field.val()
  if value.length > 6
    field.val(value.slice(value.length-6,value.length-3))

