# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
jQuery ->
  $('#search-acceptance-list-number').keydown (e) ->
    if e.keyCode == 13
      value = $(this).val()
      if value.length == 6
        $(this).val(value.slice(0,3))
