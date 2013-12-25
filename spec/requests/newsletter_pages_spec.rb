require 'spec_helper'

describe "Newsletter" do
  subject { page }

  let(:user) { FactoryGirl.create(:user) }
  let(:admin) { FactoryGirl.create(:admin) }

  describe 'create' do

    describe 'by admin user' do
      before { sign_in admin }

      it 'should create new content' do
        visit new_news_path
        page.find_field('Issue').
          value.should eq "1/#{Time.now.year}"
        page.find_field('Author').
          value.should eq "1"
        
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
    end

    describe 'by regular user' do
      before { sign_in user }

      it 'should not create new content'
    end

  end

  describe 'update' do

    describe 'by regular user' do
      before { sign_in user }

      it "should not update news"

    end

    describe 'by admin user' do
      before { sign_in admin }

      it "should update news"

    end

  end

  describe 'send' do
    before { sign_in admin }

    it 'should succeed for subscribers'

    it 'should fail for non subscribers'
  end

end
