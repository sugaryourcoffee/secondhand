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

  describe "another user's profile page" do
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

    it { should have_content('List Registration') }
    it { should have_selector('label', text: 'Enter registration code:') }
    it { should have_button('Register List') }
    it { should have_content('List Administration') }
    it { should have_content('You have no registered lists yet') }

  end

  describe "list registration" do
    let(:event) { FactoryGirl.create(:active) }
    let!(:list1) do
      FactoryGirl.create(:list, event: event, list_number: 1, 
                         registration_code: "1abcde") 
    end
    let!(:list2) do
      FactoryGirl.create(:list, event: event, list_number: 2,
                         registration_code: "2fghij") 
    end

    let(:user) { FactoryGirl.create(:user) }
    before do
      sign_in user
      visit user_path(user) 
    end

    it { should have_selector('h1', text: user.first_name) }
    it { should have_title("#{user.first_name}") }

    it { should have_content('List Registration') }
    it { should have_selector('label', text: 'Enter registration code:') }
    it { should have_button('Register List') }
    it { should have_content('List Administration') }
    it { should have_content('You have no registered lists yet') }

    describe "with empty registration code" do
      before do
        register_list("")
      end

      it { should_not have_content('List registered') }
      it { should have_content('Registration code not valid') }
      it { should have_content('You have no registered lists yet') }
    end

    describe "with wrong registration code show error" do
      before do
        register_list("wrong")
      end

      it { should have_content('Registration code not valid') }
      it { should have_content('You have no registered lists yet') }
    end
    
    describe "with correct registration code" do
      before do
        register_list("1abcde")
      end
      
      it { should_not have_content('You have no registered lists yet') }
      it { should have_content('List registered') }
      it { should have_button('List 1') }
    end

    describe "with multiple lists" do
      before do
        register_list("1abcde")
        register_list("2fghij")
      end

      it { should_not have_content('You have no registered lists yet') }
      it { should have_content('List registered') }
      it { should have_button('List 1') }
      it { should have_button('List 2') }
    end

    describe "with taken registration code" do
      before do
        register_list("1abcde")
        register_list("1abcde")
      end

      it { should have_content('Registration code already taken') }
    end

    describe "with registration code from inactive event" do
      let(:inactive) { FactoryGirl.create(:event) }
      let!(:list3) { FactoryGirl.create(:list, event: inactive,
                                        registration_code: "3klmno",
                                        list_number: 3) }
      let!(:list4) { FactoryGirl.create(:list, event: inactive,
                                        registration_code: "4pqrst",
                                        list_number: 4) }
      before { register_list("3klmno") }

      it { should have_content('Registration code not valid') }
    end

  end

  describe "list administration" do

    let(:user) { FactoryGirl.create(:user) }
    let(:event) { FactoryGirl.create(:active) }
    let!(:list) { FactoryGirl.create(:assigned, list_number: 1, 
                                    event: event, user: user) }

    before do
      sign_in user
      visit user_path(user)
    end

    it { should have_selector('h1', text: user.first_name) }
    it { should have_title("#{user.first_name}") }

    it { should have_content('List Registration') }
    it { should have_selector('label', text: 'Enter registration code:') }
    it { should have_button('Register List') }
    it { should have_content('List Administration') }
    it { should have_button('List 1') }
    it { should have_content('Process') }
    it { should have_link('Item collection', href: list_items_path(list)) }
    it { should have_link('Container color', href: list_edit_path(list)) }
    it { should have_content('Print') }
    it { should have_link('List', href: list_print_path(list)) }
    it { should have_link('Label', href: list_labels_print_path(list)) }

    describe "enter container color" do
      pending "needs to be implemented"
    end

    describe "item collection" do
      pending "needs to be implemented"
    end

    describe "print list" do
      pending "needs to be implemented"
    end

    describe "create labels" do
      pending "needs to be implemented"
    end

    describe "delete list" do
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
