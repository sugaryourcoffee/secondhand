require 'spec_helper'

describe "news pages" do
  let(:news) { FactoryGirl.create(:news) }
  let!(:news_translation_en) { 
    FactoryGirl.create(:news_translation, news: news, language: "en") 
  }

  let!(:news_translation_de) { 
    FactoryGirl.create(:news_translation, news: news, language: "de")
  }

  subject { page }

  describe "index" do
    before { visit news_index_path(locale: :en) }

    describe "visting by not signed in user" do
      it { should_not have_title("News") }
      it { should_not have_selector('h1', text: "News") }
    end

    describe "visiting by signed in user" do
      let(:user) { FactoryGirl.create(:user) }

      before do
        sign_in(user)
        visit news_index_path(locale: :en)
      end

      it { should_not have_title("News") }
      it { should_not have_selector('h1', text: "News") }
    end

    describe "visiting by admin user" do
      let(:admin) { FactoryGirl.create(:admin) }

      before do
        sign_in(admin)
        visit news_index_path(locale: :en)
      end

      it { should have_title("News") }
      it { should have_selector('h1', text: "News") }

      it "should show news" do
        translation = news.news_translation("en")
        page.should have_text translation.language 
        page.should have_text translation.title 
        page.should have_text translation.description
      end

    end
  end

  describe "show" do
    before { visit news_path(news, locale: :en) }

    describe "visting by not signed in user" do
      it { should_not have_title("News") }
      it { should_not have_selector('h1', text: "News") }
    end

    describe "visiting by signed in user" do
      let(:user) { FactoryGirl.create(:user) }

      before do
        sign_in(user)
        visit news_path(news, locale: :en)
      end

      it { should_not have_title("News") }
      it { should_not have_selector('h1', text: "News") }
    end

    describe "visiting by admin user" do
      let(:admin) { FactoryGirl.create(:admin) }

      before do
        sign_in(admin)
        visit news_path(news, locale: :en)
      end

      it { should have_title("Show news") }
      it { should have_selector('h1', text: "Show news") }

      it "should show news" do
        page.should have_text news.author
        page.should have_text news.issue
      
        translation = news.news_translation("en")
        page.should have_text translation.language 
        page.should have_text translation.title 
        page.should have_text translation.description
      end

    end
  end
end
