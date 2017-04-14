# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

source = null

stream_handler = (e) ->
  message = $.parseJSON(e.data)
  if message.done
    source.removeEventListener('message', stream_handler)
    source.close()
    download_url = $('#download-lists-as-pdf').attr('href')
                                             .replace(/(?=file=).*$/,
                                                      "file=#{message.file}")
    $('#download-lists-as-pdf').attr('href', download_url)
    $('#download-lists-as-pdf').show()
  else
    $('#create-lists-as-pdf-status').text("#{message.page}/#{message.pages}")
    $('#create-lists-as-pdf-progress').attr('value', message.page)
    $('#create-lists-as-pdf-progress').attr('max', message.pages)

$ ->
  $("a[data-create-lists-as-pdf]").click (e) ->
    e.preventDefault()
    $('#download-lists-as-pdf').hide()
    $('#progress-bar').show()
    event_id = $('a[data-create-lists-as-pdf]').attr('data-event-id')
    source = new EventSource("/events/#{event_id}/create_lists_as_pdf")
    source.addEventListener('message', stream_handler)

  $('#download-lists-as-pdf').click (e) ->
    $('#progress-bar').hide()
    $('#create-lists-as-pdf').show()
