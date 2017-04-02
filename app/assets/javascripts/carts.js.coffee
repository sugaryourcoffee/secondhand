# Reads the value in the #search_list_number text_field and checks whether the
# #search_item_number text_field is empty. This is an indication that it has 
# been entered by a barcode scanner. In this case the first digits up to the
# value length - 3 are added to the #search_list_number text_field and the 
# following 2 digits to the #search_item_number field. If the 
# #search_item_number text_field is not empty the original value is left in 
# the field. The last value is the check digit which is currently not checked
jQuery ->
  $('#search_list_number').keydown (e) ->
    if e.keyCode == 13
      value = $(this).val().replace(/^\s+|\s+$/g, "")
      if $('#search_item_number').val().replace(/^\s+|\s+$/g, "") is ""
        $(this).val(value.slice(0,value.length-3))
        $('#search_item_number').val(value.slice(value.length-3,value.length-1))
