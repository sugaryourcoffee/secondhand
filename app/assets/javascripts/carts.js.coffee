# Reads the value in the #search_list_number text_field and checks whether it
# is of size 6. This is an indication that it has been entered by a barcode
# scanner. In this case the first 3 digits are added to the #search_list_number
# field and the following 2 digits to the #search_item_number field. If the
# size is unequal to 6 the original value is left in the field. The 6th value
# is the check digit which is currently not checked
$(document).ready ->
  $('#search_list_number').keydown (e) ->
    if e.keyCode == 13
      value = $(this).val()
      if value.length == 6
        $(this).val(value.slice(0,3))
        $('#search_item_number').val(value.slice(3,5))
