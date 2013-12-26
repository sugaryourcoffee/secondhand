require 'spec_helper'

describe "Newsletter" do
  subject { page }

  let(:user) { FactoryGirl.create(:user) }
  let(:admin) { FactoryGirl.create(:admin) }
  let!(:news) { FactoryGirl.create(:news) }
  let!(:news_translation_de) { FactoryGirl.create(:news_translation, news: news,
                                                  language: "de") }
  let!(:news_translation_en) { FactoryGirl.create(:news_translation, news: news,
                                                  language: "en") }

  describe 'create' do

    describe 'by admin user' do
      before { sign_in admin }

      it 'should create new content' do
        visit new_news_path
        page.find_field('Issue').
          value.should eq "2/#{Time.now.year}"
        page.find_field('Author').
          value.should eq "#{admin.id}"
        
        select 'Deutsch', from: 'news_news_translations_attributes_0_language'
        fill_in 'news_news_translations_attributes_0_title', with: "Titel"
        fill_in 'news_news_translations_attributes_0_description', 
                with: "Das ist ein Deutscher Text"

        select 'English', from: 'news_news_translations_attributes_1_language'
        fill_in 'news_news_translations_attributes_1_title', with: 'Title'
        fill_in 'news_news_translations_attributes_1_description', 
                with: "This is an English Text" 

        check 'Released'
        check 'Promote to Frontpage'

        expect { click_button 'Create new news' }.to change(News, :count).by 1

      end

      it "should show errors on unclomplete input" do
        visit new_news_path

        page.all('input', visible: true).size.should eq 9

        expect { click_button 'Create new news' }.to change(News, :count).by 0
        page.should have_text "error"

        page.all('input', visible: true).size.should eq 9
      end
    end

    describe 'by regular user' do
      before { sign_in user }

      it 'should not create new content' do
        visit new_news_path

        page.current_path.should eq root_path(locale: :en)
      end
    end

  end

  describe 'update' do

    describe 'by regular user' do
      before { sign_in user }

      it "should not update news" do
        visit edit_news_path(news, locale: :en)

        current_path.should eq root_path(locale: :en)
      end

    end

    describe 'by admin user' do
      before { sign_in admin }

      it "should update news" do
        visit edit_news_path(news, locale: :en)

        fill_in 'news_news_translations_attributes_0_title', with: "Titel neu"
        fill_in 'news_news_translations_attributes_1_title', with: "Title new"

        expect { click_button 'Save changes' }.to change(News, :count).by 0
        
        news.reload.news_translation(:de).title.should eq "Titel neu"
        news.reload.news_translation(:en).title.should eq "Title new"

        current_path.should eq news_path(news, locale: :en)
      end

    end

  end

  describe 'destroy' do
    
    describe 'by regular user' do
      before { sign_in user }

      it 'should not destroy news' do
        visit news_index_path(locale: :en)
        current_path.should eq root_path(locale: :en)
      end
    end

    describe 'by admin user' do
      before { sign_in admin }

      it 'should destroy news and associated news_translations' do
        visit news_index_path(locale: :en)
        expect { click_link 'Destroy' }.to change(News, :count).by -1
        NewsTranslation.all.size.should eq 0
      end
    end
  end

  describe 'promote to frontpage' do
    let!(:promote_news) { FactoryGirl.create(:news,
                                             promote_to_frontpage: true,
                                             released: true) }
    let!(:news_translation_en_2) { FactoryGirl.create(:news_translation,
                                                      title: "Released promoted",
                                                      news: promote_news,
                                                      language: :en) }
    let!(:news_translation_de_2) { FactoryGirl.create(:news_translation,
                                        title: "Freigegeben veroeffentlicht",
                                        news: promote_news,
                                        language: :de) }

    let!(:unreleased_promote_news) { FactoryGirl.create(:news, 
                                                        promote_to_frontpage: true,
                                                        released: false) }
    let!(:news_translation_en_1) { FactoryGirl.create(:news_translation,
                                                      title: "Unreleased promoted",
                                                      news: unreleased_promote_news,
                                                      language: :en) }
    let!(:news_translation_de_1) { FactoryGirl.create(:news_translation,
                                        title: "Nicht freigegeben veroeffentlicht",
                                        news: unreleased_promote_news,
                                        language: :de) }

    it "should not show unreleased news" do
      visit root_path

      page.should     have_text promote_news.news_translation(:en).title
      page.should_not have_text unreleased_promote_news.news_translation(:en).title
    end

    it "should show released news marked as promoted to frontpage" do
      visit root_path

      page.should have_text promote_news.news_translation(:en).title
    end

  end

  describe 'do not promote to frontpage' do
    let!(:promote_news) { FactoryGirl.create(:news,
                                             promote_to_frontpage: true,
                                             released: true) }
    let!(:news_translation_en_2) { FactoryGirl.create(:news_translation,
                                                      title: "Released promoted",
                                                      news: promote_news,
                                                      language: :en) }
    let!(:news_translation_de_2) { FactoryGirl.create(:news_translation,
                                        title: "Freigegeben veroeffentlicht",
                                        news: promote_news,
                                        language: :de) }

    let!(:released_news) { FactoryGirl.create(:news, 
                                              promote_to_frontpage: false,
                                              released: true) }
    let!(:news_translation_en_3) { FactoryGirl.create(:news_translation,
                                                      title: "Released not promoted",
                                                      news: released_news,
                                                      language: :en) }
    let!(:news_translation_de_3) { FactoryGirl.create(:news_translation,
                                        title: "Freigegeben nicht veroeffentlicht",
                                        news: released_news,
                                        language: :de) }

    it "should not show released news not marked as promoted to frontpage" do
      visit root_path

      page.should     have_text promote_news.news_translation(:en).title
      page.should_not have_text released_news.news_translation(:en).title
    end
  end

  describe 'send' do
    before { sign_in admin }

    it 'should show send link for released and unsent messages' do
      visit news_index_path(:en)
      page.should have_link 'Send'
    end
    
    it 'should succeed for subscribers'

    it 'should fail for non subscribers'

    it 'should not send already sent messages'

    it 'should show send button for released updated messages'
  end

end
