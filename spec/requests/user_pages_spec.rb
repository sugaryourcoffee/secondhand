require 'spec_helper'

describe "User pages" do
  subject { page }

  describe "index" do

    let(:user) { FactoryGirl.create(:user) }

    before do
      sign_in user
      visit users_path
    end

    it { should_not have_title('All users') }
    it { should_not have_selector('h1', text: 'All users') }

    describe "as admin user" do
      let(:admin) { FactoryGirl.create(:admin) }

      before do
        sign_in admin
        visit users_path
      end

      it "should list each user" do
        User.paginate(page: 1).each do |user|
          page.should have_selector('li', 
                                   text: "#{user.first_name} #{user.last_name}")
        end
      end

    end

    describe "delete links" do
      it { should_not have_link('delete') }

      describe "as an admin user" do
        let(:admin) { FactoryGirl.create(:admin) }
        before do
          sign_in admin
          visit users_path
        end

        it { should have_link('delete', href: user_path(User.first)) }
        it "should be able to delete another user" do
          expect { click_link('delete') }.to change(User, :count).by(-1)
        end
        it { should_not have_link('delete', href: user_path(admin)) }
      end
    end

  end

  describe "signup page" do
    before { visit signup_path }

    it { should have_selector('h1',    text: 'Sign up') }
    it { should have_title('Sign up') }
  end

  describe "another user's profile age" do
    let(:user) { FactoryGirl.create(:user) }

    before { visit user_path(user) }

    it { should_not have_selector('h1', text: user.first_name) }
    it { should_not have_title(user.first_name) }
  end

  describe "own profile page" do
    let(:user) { FactoryGirl.create(:user) }
    before do
      sign_in user
      visit user_path(user) 
    end

    it { should have_selector('h1', text: user.first_name) }
    it { should have_title("#{user.first_name}") }

    it { should have_button('Register List') }

    describe "after registering list show list in administration section" do
      pending "needs to be implemented"
    end

    describe "after registering taken list show error" do
      pending "needs to be implemented"
    end

    describe "after registering empty list show error" do
      pending "needs to be implemented"
    end

    describe "after registering with wrong registration code show error" do
      pending "needs to be implemented"
    end
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
        fill_in "Confirm Password", with: "pa55w0rd"
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

  describe "edit" do
    let(:user) { FactoryGirl.create(:user) }
    before do
      sign_in user
      visit edit_user_path(user) 
    end

    describe "page" do
      it { should have_selector('h1', text: "Update your profile") }
      it { should have_title("Edit user") }
      it { should have_link('change', href: 'http://gravatar.com/emails') }
    end

    describe "with invalid information" do
      before { click_button "Save changes" }

      it { should have_content('error') }
    end

    describe "with valid information" do
      let(:new_first_name) { "New First Name" }
      let(:new_email) { "new@example.com" }
      before do
        fill_in "First name", with: new_first_name
        fill_in "E-Mail", with: new_email
        fill_in "Password", with: user.password
        fill_in "Confirm Password", with: user.password
        click_button "Save changes"
      end

      it { should have_title("#{user.last_name}, #{new_first_name}") }
      it { should have_selector('div.alert.alert-success') }
      it { should have_link('Sign out', href: signout_path) }
      specify { user.reload.first_name.should == new_first_name }
      specify { user.reload.email.should == new_email }
    end
  end
end
