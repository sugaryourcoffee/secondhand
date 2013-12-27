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
        mail.subject.should eq("Title")
        mail.to.should eq(["mail@boerse-burgthann.de"])
        mail.bcc.should eq([user_english.email])
        mail.from.should eq(["mail@boerse-burgthann.de"])
      end

      it "renders the body" do
        mail.body.encoded.should match(news.news_translation(:en).description)
      end
    end

    describe 'in Deutsch' do
      let(:mail) { Newsletter.publish(news.news_translation(:de),
                                      User.subscribers(:de)) }

      it "renders the headers" do
        mail.subject.should eq(news.news_translation(:de).title)
        mail.to.should eq(["mail@boerse-burgthann.de"])
        mail.bcc.should eq([admin.email, user_german.email])
        mail.from.should eq(["mail@boerse-burgthann.de"])
      end

      it "renders the body" do
        mail.body.encoded.should match(news.news_translation(:de).description)
      end
    end
  end
end
