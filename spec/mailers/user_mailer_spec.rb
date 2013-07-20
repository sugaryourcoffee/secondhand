require "spec_helper"

describe UserMailer do
  describe "password_reset" do
    let(:user) { FactoryGirl.create(:user, email: "to@example.com") }
    I18n.locale = :en
    let(:mail) { user.send_password_reset }

    it "renders the headers" do
      mail.subject.should eq("Password Reset")
      mail.to.should eq(["to@example.com"])
      mail.from.should eq(["mail@boerse-burgthann.de"])
    end

    it "renders the body" do
      mail.body.encoded.should match("To reset your password, click the URL")
    end
  end

end
