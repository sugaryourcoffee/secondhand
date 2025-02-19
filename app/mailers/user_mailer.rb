# frozen_string_literal: true

# Manages sending of e-mails for different occasions
# * user requests
# * user registrations
# * list registrations
# * list de-registrations
class UserMailer < ActionMailer::Base
  default from: 'mail@boerse-burgthann.de'

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.password_reset.subject
  #
  def password_reset(user)
    @user = user
    mail to: user.email
  end

  def user_request(message)
    @message = message
    if message.copy_me == "0"
      user_request_do_not_copy_me(message)
    else
      user_request_copy_me(message)
    end
  end

  def registered(user)
    @user = user
    mail from: 'mail@boerse-burgthann.de',
         to: 'verkaeufe@boerse-burgthann.de',
         bcc: 'pierre@sugaryourcoffee.de',
         subject: "[User registration] #{user.email}"
  end

  def list_registered(user, list)
    @user = user
    @list = list
    mail from: 'mail@boerse-burgthann.de',
         to: 'verkaeufe@boerse-burgthann.de',
         bcc: 'pierre@sugaryourcoffee.de',
         subject: "[List registration] #{list.list_number}"
  end

  def list_deregistered(user, list)
    @user = user
    @list = list
    mail from: 'mail@boerse-burgthann.de',
         to: 'verkaeufe@boerse-burgthann.de',
         bcc: 'pierre@sugaryourcoffee.de',
         subject: "[List deregistration] #{list.list_number}"
  end

  private

  def user_request_copy_me(message)
    mail from: 'mail@boerse-burgthann.de',
         to: 'mail@boerse-burgthann.de',
         cc: message.email,
         bcc: 'pierre@sugaryourcoffee.de',
         subject: "[#{message.category}] #{message.subject}"
  end

  def user_request_do_not_copy_me(message)
    mail from: 'mail@boerse-burgthann.de',
         to: 'mail@boerse-burgthann.de',
         bcc: 'pierre@sugaryourcoffee.de',
         subject: "[#{message.category}]/[#{message.email}] #{message.subject}"
  end
end
