require "spec_helper"

describe Newsletter do
  describe "publish" do
    let!(:admin) { FactoryGirl.create(:admin, preferred_language: "de") }
    let!(:user_german)  { FactoryGirl.create(:user, preferred_language: "de") }
    let!(:user_english) { FactoryGirl.create(:user, preferred_language: "en") }

    let!(:news) { FactoryGirl.create(:news, user: admin) }

    let!(:news_translation_de) { FactoryGirl.create(:news_translation, news: news,
                                                    title: 'Titel',
                                                    language: :de,
                                                    description: 'Beschreibung') }
    let!(:news_translation_en) { FactoryGirl.create(:news_translation, news: news,
                                                    title: 'Title',
                                                    language: :en,
                                                    description: 'Description') }

    describe 'in English' do
      let(:mail) { Newsletter.publish(news.news_translation(:en),
                                      User.subscribers(:en)) }

      it "renders the headers" do
        expect(mail.subject).to eq("Title")
        expect(mail.to).to eq(["mail@boerse-burgthann.de"])
        expect(mail.bcc).to eq([user_english.email])
        expect(mail.from).to eq(["mail@boerse-burgthann.de"])
      end

      it "renders the body" do
        expect(mail.body.encoded).to match(news.news_translation(:en).description)
      end
    end

    describe 'in Deutsch' do
      let(:mail) { Newsletter.publish(news.news_translation(:de),
                                      User.subscribers(:de)) }

      it "renders the headers" do
        expect(mail.subject).to eq(news.news_translation(:de).title)
        expect(mail.to).to eq(["mail@boerse-burgthann.de"])
        expect(mail.bcc).to eq([admin.email, user_german.email])
        expect(mail.from).to eq(["mail@boerse-burgthann.de"])
      end

      it "renders the body" do
        expect(mail.body.encoded).to match(news.news_translation(:de).description)
      end
    end
  end
end
