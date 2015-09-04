Development Notes
=================
Here you will find notes on topics that needed some research to get tackled and
are off the standard rails path. Also there are some gotchas that are rarely
used.

Views
=====
Topics related to views can be found here.

Read User Input from Textfield and split into different Textfields
------------------------------------------------------------------
When collecting *Items* in a sales transaction or *Lineitems* in a redemption
transaction the *list number* and the *item number* have to be entered in to
different fields. When working with a barcode scanner the *list number* and 
*item number* are read into one field. This entry has to be split up into 
*list number* and *item number* and entered programatically into the two
respective fields.

### How to
When the user enters the page the focus has to be on the *list number* field.
That is the *list number* field needs `autofocus: true`. If there is a value
from a previous scan we need to overwrite this with a new scan. In order to
accomplish that we need to select the value on focus with 
`onfocus: "this.select()`

Here is the view code for the above described approach.

    <%= text_field_tag :search_list_number, params[:search_list_number], 
                       autofocus: true, onfocus: "this.select()",
                       class: "input-medium search-query" %>

The next step is to read the value from the *list number* field. To do this we
listen on the `keydown` event of the `search_list_number` field. If the key is
`CR` we check whether the field contains 6 characters, 3 for the *list number*,
2 for the *item number* and 1 for the *check digit*. If so we split the value
and add the first 3 characters to the `search_list_number` field and the next 2
characters into the `search_item_number` text field. If the character count is
less than 6 digits we don't do nothing.

The coffee script code looks like this.

    $(document).ready ->
      $('#search_list_number').keydown (e) ->
        if e.keyCode == 13
          value = $(this).val()
          if value.length == 6
            $(this).val(value.slice(0,3))
            $('#search_item_number').val(value.slice(3,5))

