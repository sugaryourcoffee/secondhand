# Load the Rails application
require File.expand_path('../application', __FILE__)

# Initialize the Rails application
Rails.application.initialize!

Rails.application.configure do
  config.action_mailer.delivery_method = :sendmail
  config.action_mailer.sendmail_settings = {
    location: '/usr/sbin/sendmail',
    arguments: '-i -t'
  }
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true
end

ActionMailer::Base.smtp_settings[:enable_starttls_auto] = false
