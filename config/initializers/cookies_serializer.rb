# Be sure to restart your server when you modify this file.

# after upgrade to rails 4.2 changed from :json to hybrid
# :json produced an error:
# JSON::ParserError (765: unexpected token at
# {I"session_id:ETI"%05ab6d22f4b16ef34d85820da6eaa357;')
 
Rails.application.config.action_dispatch.cookies_serializer = :hybrid
