class ListNotifier < ActionMailer::Base
  default from: "Boerse Burgthann <mail@boerse-burgthann.de>"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.list_notifier.received.subject
  #
  def received(list)
    @list = list
    csv = list.as_csv_file
    attachments[csv] = File.read(csv)
    mail to: list.user.email, bcc: "mail@boerse-burgthann.de"
  end
end
