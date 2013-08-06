class UserMailer < ActionMailer::Base
  default from: "mail@boerse-burgthann.de"

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
    if message.copy_me
      mail from: message.email, 
           to:   "mail@boerse-burgthann.de",
           cc:   message.email,
           bcc: "pierre@sugaryourcoffee.de", 
           subject: "[#{message.category}] #{message.subject}"
    else
      mail from: message.email, 
           to:   "mail@boerse-burgthann.de",
           bcc: "pierre@sugaryourcoffee.de", 
           subject: "[#{message.category}] #{message.subject}"
    end
  end

  def registered(user)
    @user = user
    mail from: user.email,
         to:   "mail@boerse-burgthann.de",
         bcc:  "pierre@sugaryourcoffee.de",
         subject: "[User registration] #{user.email}"
  end

  def list_registered(user, list)
    @user = user
    @list = list
    mail from: user.email,
         to:   "mail@boerse-burgthann.de",
         bcc:  "pierre@sugaryourcoffee.de",
         subject: "[List registration] #{list.list_number}"
  end
end
