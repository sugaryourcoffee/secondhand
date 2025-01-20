# frozen_string_literal: true

# Sends e-mail to seller with labels in pdf- and list in csv-format
class ListNotifier < ActionMailer::Base
  default from: 'Boerse Burgthann <mail@boerse-burgthann.de>'

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.list_notifier.received.subject
  #
  def received(list)
    @list = list
    csv = list.as_csv_file
    attachments[csv] = File.read(csv)
    pdf = list.labels_pdf(true)
    attachments[pdf] = File.read(pdf)
    mail to: list.user.email,
         bcc: 'verkaeufe@boerse-burgthann.de',
         subject: default_i18n_subject(
           list_number: format('%03d', list.list_number)
         )
  end
end
