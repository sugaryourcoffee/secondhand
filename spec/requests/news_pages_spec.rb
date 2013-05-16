require 'spec_helper'

describe "news pages" do
  subject { page }

  describe "index" do
    before { visit news_index_path}

    describe "visting by not signed in user" do
      it { should_not have_title("News") }
      it { should_not have_selector('h1', text: "News") }
    end

    describe "visiting by signed in user" do
      let(:user) { FactoryGirl.create(:user) }

      before do
        sign_in(user)
        visit news_index_path
      end

      it { should_not have_title("News") }
      it { should_not have_selector('h1', text: "News") }
    end

    describe "visitin by admin user" do
      let(:admin) { FactoryGirl.create(:admin) }

      before do
        sign_in(admin)
        visit news_index_path
      end

      it { should have_title("News") }
      it { should have_selector('h1', text: "News") }

    end
  end
end
