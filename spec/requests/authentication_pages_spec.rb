require 'spec_helper'

describe "Authentication" do
  subject { page }
  describe "signin page" do
    before { visit signin_path(locale: :en) }
      
    it { should have_selector('h1', text: 'Sign in') }
    it { should have_title('Sign in') } 
  end

  describe "signin" do
    before { visit signin_path(locale: :en) }

    describe "with invalid information" do
      before { click_button "Sign in" }

      it { should have_title('Sign in') }
      it { should have_error_message('Invalid') }

      describe "after visiting another page" do
        before { click_link "Home" }
        it { should_not have_selector('div.alert.alert-error') }
      end
    end

    describe "with valid information" do
      let(:user) { FactoryGirl.create(:user) }
      before { sign_in(user) }
      
      it { should have_title("#{user.last_name}, #{user.first_name}") }
      it { should_not have_link('Events', href: events_path(locale: :en)) }
      it { should_not have_link('Lists', href: lists_path(locale: :en)) }
      it { should_not have_link('Users', href: users_path(locale: :en)) }
      it { should have_link('My Lists', href: user_path(user, locale: :en)) }
      it { should have_link('Settings', href: edit_user_path(user, locale: :en)) }
      it { should have_link('Sign out', href: signout_path(locale: :en)) }
      it { should_not have_link('Sign in', href: signin_path(locale: :en)) }

      describe "followed by signout" do
        before { click_link 'Sign out' }
        it { should have_link('Sign in') }
      end
    end
  end

  describe "authorization" do

    describe "for non-signed-in users" do
      let(:user) { FactoryGirl.create(:user) }

      describe "when attempting to visit a protected page" do
        before do
          visit edit_user_path(user, locale: :en)
          fill_in "E-Mail", with: user.email
          fill_in "Password", with: user.password
          click_button "Sign in"
        end

        describe "after signing in" do

          it "should render the desired protected page" do
            page.should have_title('Edit user')
          end
        end
      end

      describe "in the Users controller" do

        describe "visiting the edit page" do
          before { visit edit_user_path(user, locale: :en) }
          it { should have_title('Sign in') }
        end

        describe "submitting to the update action" do
          before { put user_path(user, locale: :en) }
          specify { response.should redirect_to(signin_path(locale: :en)) }
        end

        describe "visiting the user index" do
          before { visit users_path(locale: :en) }
          it { should have_title('Sign in') }
        end
      end

      describe "as wrong user" do
        let(:user) { FactoryGirl.create(:user) }
        let(:wrong_user) do 
          FactoryGirl.create(:user, email: "wrong@example.com")
        end
        before { sign_in user }

        describe "visiting Users#edit page" do
          before { visit edit_user_path(wrong_user, locale: :en) }
          it { should_not have_title(full_title('Edit user')) }
        end

        describe "submitting a PUT request to the Users#update action" do
          before { put user_path(wrong_user, locale: :en) }
          specify { response.should redirect_to(root_path(locale: :en)) }
        end
      end

      describe "as non-admin user" do
        let(:user) { FactoryGirl.create(:user) }
        let(:non_admin) { FactoryGirl.create(:user) }

        before { sign_in non_admin }

        describe "submitting a DELETE request to the Users#destroy action" do
          before { delete user_path(user, locale: :en) }
          specify { response.should redirect_to(root_path) }
        end
      end
    end
  end
end
