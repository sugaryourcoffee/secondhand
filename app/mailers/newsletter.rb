# frozen_string_literal: true

# Sends newsletter to users that have registered for newsletters
class Newsletter < ActionMailer::Base
  default from: 'mail@boerse-burgthann.de'

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.newsletter.publish.subject
  #
  def publish(news, subscribers)
    @description = news.description

    mail to: 'mail@boerse-burgthann.de',
         bcc: subscribers.join(','),
         subject: news.title
  end
end
