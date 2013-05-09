require 'spec_helper'

describe "User pages" do
  subject { page }

  describe "signup page" do
    before { visit signup_path }

    it { should have_selector('h1',    text: 'Sign up') }
    it { should have_title('Sign up') }
  end

  describe "profile page" do
    let(:user) { FactoryGirl.create(:user) }
    before { visit user_path(user) }

    it { should have_selector('h1', text: user.first_name) }
    it { should have_title("#{user.first_name}") }
  end

  describe "signup" do
    before { visit signup_path }

    let(:submit) { "Create my account" }

    describe "with invalid information" do
      it "should not create a user" do
        expect { click_button submit }.not_to change(User, :count)
      end
    end

    describe "with valid information" do
      before do
        fill_in "First name", with: "Example"
        fill_in "Last name", with: "User"
        fill_in "Street", with: "Street 123"
        fill_in "Zip code", with: "12345"
        fill_in "Town", with: "Town"
        fill_in "Country", with: "Country"
        fill_in "Phone", with: "1234567890"
        fill_in "E-Mail", with: "user@example.com"
        fill_in "Password", with: "pa55w0rd"
        fill_in "Confirmation", with: "pa55w0rd"
      end

      it "should create a user" do
        expect { click_button submit }.to change(User, :count).by(1)
      end

      describe "after saving the user" do
        before { click_button submit }
        let(:user) { User.find_by_email('user@example.com') }

        it { should have_title("#{user.last_name}, #{user.first_name}") }
        it { should have_link('Sign out') }
      end
    end

  end
end
