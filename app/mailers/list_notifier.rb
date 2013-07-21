class ListNotifier < ActionMailer::Base
  default from: "Boerse Burgthann <mail@boerse-burgthann.de>"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.list_notifier.received.subject
  #
  def received(list)
    @list = list
    attachments["#{list.list_number}.csv"] = File.read(list.as_csv)
    mail to: list.user.email, bcc: "mail@boerse-burgthann.de", 
         subject: "Empfangsbestaetigung fuer Liste #{ list.list_number }"
  end
end
