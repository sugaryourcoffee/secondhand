require "spec_helper"

describe UserMailer do
  describe "password_reset" do
    let(:user) { FactoryGirl.create(:user, email: "to@example.com") }
    I18n.locale = :en
    let(:mail) { user.send_password_reset }

    it "renders the headers" do
      expect(mail.subject).to eq("Password Reset")
      expect(mail.to).to eq(["to@example.com"])
      expect(mail.from).to eq(["mail@boerse-burgthann.de"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("To reset your password, click the URL")
    end
  end

end
