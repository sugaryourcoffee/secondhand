require 'spec_helper'

describe "Newsletter" do
  subject { page }

  let(:user) { FactoryGirl.create(:user) }
  let(:admin) { FactoryGirl.create(:admin) }
  let!(:news) { FactoryGirl.create(:news, released: false) }
  let!(:news_translation_de) { FactoryGirl.create(:news_translation, news: news,
                                                  language: "de") }
  let!(:news_translation_en) { FactoryGirl.create(:news_translation, news: news,
                                                  language: "en") }

  describe 'create' do

    describe 'by admin user' do
      before { sign_in admin }

      it 'should create new content' do
        visit new_news_path
        expect(page.find_field('Issue').
          value).to eq "2/#{Time.now.year}"
        expect(page.find_field('Author').
          value).to eq "#{admin.id}"
        
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

      it "should show errors on inclomplete input" do
        visit new_news_path

        expect(page.all('input'   ).size).to eq 6
        expect(page.all('textarea').size).to eq 2

        expect { click_button 'Create new news' }.to change(News, :count).by 0
        expect(page).to have_text "error"

        expect(page.all('input'   ).size).to eq 6
        expect(page.all('textarea').size).to eq 2
      end
    end

    describe 'by regular user' do
      before { sign_in user }

      it 'should not create new content' do
        visit new_news_path

        expect(page.current_path).to eq root_path(locale: :en)
      end
    end

  end

  describe 'update' do

    describe 'by regular user' do
      before { sign_in user }

      it "should not update news" do
        visit edit_news_path(news, locale: :en)

        expect(current_path).to eq root_path(locale: :en)
      end

    end

    describe 'by admin user' do
      before { sign_in admin }

      it "should update news" do
        visit edit_news_path(news, locale: :en)

        fill_in 'news_news_translations_attributes_0_title', with: "Titel neu"
        fill_in 'news_news_translations_attributes_1_title', with: "Title new"

        expect { click_button 'Save changes' }.to change(News, :count).by 0
        
        expect(news.reload.news_translation(:de).title).to eq "Titel neu"
        expect(news.reload.news_translation(:en).title).to eq "Title new"

        expect(current_path).to eq news_path(news, locale: :en)
      end

    end

  end

  describe 'destroy' do
    
    describe 'by regular user' do
      before { sign_in user }

      it 'should not destroy news' do
        visit news_index_path(locale: :en)
        expect(current_path).to eq root_path(locale: :en)
      end
    end

    describe 'by admin user' do
      before { sign_in admin }

      it 'should destroy news and associated news_translations' do
        visit news_index_path(locale: :en)
        expect { click_link 'Destroy' }.to change(News, :count).by -1
        expect(NewsTranslation.all.size).to eq 0
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

      expect(page).to     have_text promote_news.news_translation(:en).title
      expect(page).not_to have_text unreleased_promote_news.news_translation(:en).title
    end

    it "should show released news marked as promoted to frontpage" do
      visit root_path

      expect(page).to have_text promote_news.news_translation(:en).title
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

      expect(page).to     have_text promote_news.news_translation(:en).title
      expect(page).not_to have_text released_news.news_translation(:en).title
    end
  end

  describe 'send' do

    before { sign_in admin }

    describe 'behaviour for unreleased newsletters' do
      it 'should not show send link' do
        visit news_index_path(:en)
        expect(page).not_to have_link 'Send'
      end
    end

    describe 'behaviour for released newsletters' do
      let!(:news) { FactoryGirl.create(:news) }
      let!(:news_translation_de) { FactoryGirl.create(:news_translation, news: news,
                                                      language: "de") }
      let!(:news_translation_en) { FactoryGirl.create(:news_translation, news: news,
                                                      language: "en") }

      it 'should show send link' do
        visit news_index_path(:en)
        expect(page).to have_link 'Send'
      end

      it 'should not show send link for already send newsletters' do
        visit news_index_path(:en)
        click_link 'Send'
        expect(page).to have_text 'Newsletter has been sent to subscribers'
        expect(page.current_path).to eq news_index_path(locale: :en)
        expect(page).not_to have_link 'Send'
      end
      
      it 'should show send link for already send but updated newsletters' do
        visit news_index_path(:en)
        click_link 'Send'
        expect(page).to have_text 'Newsletter has been sent to subscribers'
        expect(page).not_to have_link 'Send'
        click_link 'Edit'
        click_button 'Save changes'
        visit news_index_path(:en)
        expect(page).to have_link 'Send'
      end

    end

  end

end
