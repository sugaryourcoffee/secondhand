require 'spec_helper'

describe "User pages" do
  subject { page }

  describe "index" do

    let(:user) { FactoryGirl.create(:user) }

    before do
      sign_in user
      visit users_path(locale: :en)
    end

    it { is_expected.not_to have_title('All users') }
    it { is_expected.not_to have_selector('h1', text: 'All users') }

    describe "as admin user" do
      let(:admin) { FactoryGirl.create(:admin) }

      before do
        sign_in admin
        visit users_path(locale: :en)
      end

      it { is_expected.to have_button('Search') }

      it "should list each user" do
        User.paginate(page: 1).each do |user|
          expect(page).to have_selector('li', 
                                   text: "#{user.first_name} #{user.last_name}")
        end
      end

    end

    describe "delete links" do
      it { is_expected.not_to have_link('delete') }

      describe "as an admin user" do
        let(:admin) { FactoryGirl.create(:admin) }
        before do
          sign_in admin
          visit users_path(locale: :en)
        end

        it { is_expected.to have_link('delete', 
                              href: user_path(User.first, locale: :en)) }
        it "should be able to delete another user" do
          expect { click_link('delete') }.to change(User, :count).by(-1)
        end
        it { is_expected.not_to have_link('delete', 
                                  href: user_path(admin, locale: :en)) }
      end

      describe "not active when user has registered list" do
        let(:admin) { FactoryGirl.create(:admin) }
        let(:event) { FactoryGirl.create(:active) }
        let!(:list1) { FactoryGirl.create(:list, event: event, list_number: 1,
                                          registration_code: "2a.b.c") }
        let!(:list2) { FactoryGirl.create(:list, event: event, list_number: 2,
                                          registration_code: ".3.d.e") }
        before do
          sign_in user
          visit user_path(user, locale: :en)
          register_list("2a.b.c")
          register_list(".3.d.e")
          sign_in admin
          visit users_path(locale: :en)
        end

        it { is_expected.to have_selector("li", 
                                text: "#{user.first_name} #{user.last_name}") }
        it { is_expected.not_to have_link("delete",
                                  href: user_path(user, locale: :en)) } 

      end
    end

    describe "deactivate links" do
      it { is_expected.not_to have_link('deactivate') }

      describe "as an admin user" do
        let(:admin) { FactoryGirl.create(:admin) }
        before do
          sign_in admin
          visit users_path(locale: :en)
        end

        it { is_expected.not_to have_link('deactivate', 
                                   href: user_path(User.first, locale: :en)) }
      end

      describe "active when user has registered list" do
        let(:admin) { FactoryGirl.create(:admin) }
        let(:event) { FactoryGirl.create(:active) }
        let!(:list1) { FactoryGirl.create(:list, event: event, list_number: 1,
                                          registration_code: "2a.b.c") }
        let!(:list2) { FactoryGirl.create(:list, event: event, list_number: 2,
                                          registration_code: ".3.d.e") }
        before do
          sign_in user
          visit user_path(user, locale: :en)
          register_list("2a.b.c")
          register_list(".3.d.e")
          sign_in admin
          visit users_path(locale: :en)
        end

        it { is_expected.to have_selector("li", 
                                text: "#{user.first_name} #{user.last_name}") }
        it { is_expected.to have_link("deactivate",
                               href: deactivate_user_path(user, locale: :en)) } 
        it "should be able to deactivate another user" do
          user_last_name  = user.last_name
          user_first_name = user.first_name
          user_email      = user.email
          user_street     = user.street
          user_phone      = user.phone
          expect { click_link('deactivate') }.to change(User, :count).by(0)
          is_expected.not_to have_text(user_last_name)
          is_expected.not_to have_text(user_first_name)
          is_expected.not_to have_text(user_email)
          is_expected.not_to have_text(user_street)
          is_expected.not_to have_text(user_phone)
          is_expected.not_to have_link('deactivate', 
                               href: deactivate_user_path(user, locale: :en))
        end
      end
    end

  end

  describe "signup page" do
    before { visit signup_path(locale: :en) }

    it { is_expected.to have_selector('h1',    text: 'Sign up') }
    it { is_expected.to have_title('Sign up') }
    it { is_expected.to have_link('Open and read Privacy Statement') }
  end

  describe "sign in page" do
    before { visit signin_path(locale: :en) }

    it { is_expected.to have_link('Reset password') }
  end

  describe "another user's profile page" do
    let(:user) { FactoryGirl.create(:user) }

    before { visit user_path(user, locale: :en) }

    it { is_expected.not_to have_selector('h1', text: user.first_name) }
    it { is_expected.not_to have_title(user.first_name) }
  end

  describe "own profile page" do
    let(:user) { FactoryGirl.create(:user) }
    before do
      sign_in user
      visit user_path(user, locale: :en) 
    end

    it { is_expected.to have_selector('h1', text: user.first_name) }
    it { is_expected.to have_title("#{user.first_name}") }

    it { is_expected.to have_content('List Registration') }
    it { is_expected.to have_selector('label', text: 'Enter registration code') }
    it { is_expected.to have_button('Register List') }
    it { is_expected.to have_content('List Administration') }
    it { is_expected.to have_content('You have no registered lists yet') }

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
      visit user_path(user, locale: :en) 
    end

    it { is_expected.to have_selector('h1', text: user.first_name) }
    it { is_expected.to have_title("#{user.first_name}") }

    it { is_expected.to have_content('List Registration') }
    it { is_expected.to have_selector('label', text: 'Enter registration code') }
    it { is_expected.to have_button('Register List') }
    it { is_expected.to have_content('List Administration') }
    it { is_expected.to have_content('You have no registered lists yet') }

    describe "with empty registration code" do
      before do
        register_list("")
      end

      it { is_expected.not_to have_content('List registered') }
      it { is_expected.to have_content('Registration code not valid') }
      it { is_expected.to have_content('You have no registered lists yet') }
    end

    describe "with wrong registration code show error" do
      before do
        register_list("wrong")
      end

      it { is_expected.to have_content('Registration code not valid') }
      it { is_expected.to have_content('You have no registered lists yet') }
    end
    
    describe "with correct registration code" do
      before do
        register_list("1abcde")
      end
      
      it { is_expected.not_to have_content('You have no registered lists yet') }
      it { is_expected.to have_content('List registered') }
      it { is_expected.to have_button('List 1') }
    end

    describe "with multiple lists" do
      before do
        register_list("1abcde")
        register_list("2fghij")
      end

      it { expect(list1.reload.user_id).to eq user.id }

      it { is_expected.not_to have_content('You have no registered lists yet') }
      it { is_expected.to have_content('List registered') }
      it { is_expected.to have_button('List 1') }
      it { is_expected.to have_button('List 2') }
    end

    describe "with taken registration code" do
      before do
        register_list("1abcde")
        register_list("1abcde")
      end

      it { is_expected.to have_content('Registration code already taken') }
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

      it { is_expected.to have_content('Registration code not valid') }
    end

  end

  describe "list deregistration" do
    let(:event) { FactoryGirl.create(:active) }
    let!(:list1) do
      FactoryGirl.create(:list, event: event, list_number: 1, 
                         registration_code: "1abcde") 
    end
    let!(:list2) do
      FactoryGirl.create(:list, event: event, list_number: 2,
                         registration_code: "2fghij") 
    end

    let(:admin)      { FactoryGirl.create(:admin) }
    let(:other_user) { FactoryGirl.create(:user) }
    let(:user)       { FactoryGirl.create(:user) }

    before do
      sign_in user
      visit user_path(user, locale: :en) 
    end

    it { is_expected.to have_content('You have no registered lists yet') }

    describe "with list asigned to user" do
      before do
        register_list("2fghij")
        list2.items.create(description: "Item 1", size: "XL", price: "2.5")
        list2.items.create(description: "Item 2", size: "S", price: "1.0")
      end

      it { is_expected.to have_content('List registered') }
      it { is_expected.to have_button('List 2') }

      it { expect(list2.items.size).to eq 2 }
      it { expect(list2.reload.user_id).to eq user.id }

      it { is_expected.not_to have_link "Deregister" }

      describe "deregister list as admin" do
        before do
          sign_in admin
          visit user_path(user, locale: :en)
          click_link "Deregister"
        end
        
        it { is_expected.to have_content('List deregistered') }
        it { is_expected.not_to have_button "List 2" }
        it { expect(list2.reload.items.size).to eq 0 }
        it { expect(list2.user_id).to eq nil }

        describe "and register deregistered list as admin" do
          before do
            visit user_path(admin, locale: :en)
            register_list("2fghij")
          end

          it { is_expected.to have_content('List registered') }
          it { is_expected.to have_button "List 2" }
        end
      end
    end

    describe "with list of another user" do

      before do
        register_list("1abcde")
        list1.items.create(description: "Item 1.1", size: "S", price: 2.5)
        list1.items.create(description: "Item 1.2", size: "L", price: 3.0)
      end

      it { expect(list1.items.size).to eq 2 }
      it { expect(list1.reload.user_id).to eq user.id }

      describe "deregister other user's list with own user id" do
        before do
          sign_in other_user
          post deregister_list_user_path(other_user, 
                                         list_id: list1.id, 
                                         locale: :en)
        end

        it { expect(list1.items.size).to eq 2 }
        it { expect(list1.reload.user_id).to eq user.id }

        specify { expect(response).to redirect_to user_path(other_user, 
                                                        locale: :en) }
      end

      describe "deregister other user's list with other user's id" do

        before do
          sign_in other_user
          post deregister_list_user_path(user, list_id: list1.id, locale: :en)
        end

        it { expect(list1.items.size).to eq 2 }
        it { expect(list1.reload.user_id).to eq user.id }
        specify { expect(response).to redirect_to(root_path(locale: :en)) }

      end

    end

  end
# ----
  describe "list administration" do

    let(:user) { FactoryGirl.create(:user) }
    let(:event) { FactoryGirl.create(:active) }
    let!(:list) { FactoryGirl.create(:assigned, list_number: 1, 
                                    event: event, user: user) }

    before do
      sign_in user
      visit user_path(user, locale: :en)
    end

    it { is_expected.to have_selector('h1', text: user.first_name) }
    it { is_expected.to have_title("#{user.first_name}") }

    it { is_expected.to have_content('List Registration') }
    it { is_expected.to have_selector('label', text: 'Enter registration code') }
    it { is_expected.to have_button('Register List') }
    it { is_expected.to have_content('List Administration') }
    it { is_expected.to have_button('List 1') }
    it { is_expected.to have_content('Process') }
    it { is_expected.to have_link('Item collection', 
                          href: user_list_items_path(user, list, locale: :en)) }
    it { is_expected.to have_content('Print') }
    it { is_expected.to have_link('List', 
                          href: print_list_user_list_path(user, list, 
                                                          locale: :en)) }
    it { is_expected.to have_link('Labels', 
                          href: print_labels_user_list_path(user, list, 
                                                            locale: :en)) }
    it { is_expected.to have_content('Enter container color:') }
    it { is_expected.to have_button('Save Container Color') }

    describe "enter container color" do
      before do
        fill_in "Enter container color:", with: "Red"
        click_button "Save Container Color"
      end
      it { is_expected.to have_text('List updated!') }
    end

    describe "item collection" do

      describe "with assigned list" do
        before { click_link 'Item collection', match: :first }
        
        it { is_expected.to have_text('Collect Items') }
      end

      describe "with unassigned list" do
        let(:list) { FactoryGirl.create(:list,
                                        list_number: 1, 
                                        event: event) }

        before { visit user_list_items_path(user, list, locale: :en) }

        it { is_expected.to have_text('List number not assigned') }
      end

      describe "admin accessing other users list" do
        let(:admin) { FactoryGirl.create(:admin) }
        
        before do
          sign_in admin
          visit user_list_items_path(user, list, locale: :en)
        end

        it { is_expected.to have_text('Collect Items') }
      end
    end

    describe "print list" do
      before { visit print_list_user_list_path(user, list, format: 'pdf', locale: :en) }
      it "should render a pdf file" do
        expect(page.response_headers['Content-Disposition']).
          to include("attachment")
      end
    end

    describe "create labels" do
      before { visit print_labels_user_list_path(user, list, format: 'pdf', locale: :en) }
      it "should render a pdf file" do
        expect(page.response_headers['Content-Disposition']).
          to include("attachment")
      end
    end

  end

  describe "signup" do
    before { visit signup_path(locale: :en) }

    let(:submit) { "Create my account" }

    describe "with invalid information" do
      before do
        fill_in "First name", with: "Example"
        fill_in "Last name", with: "User"
        fill_in "Street", with: "Street 123"
        fill_in "Zip code", with: "12345"
        fill_in "Town", with: "Town"
        fill_in "Country", with: "Country"
        fill_in "Phone", with: "1234567890"
        fill_in "E-Mail", with: "user@example.com"
        fill_in "Password *", with: "pa55w0rd"
        fill_in "Confirm Password", with: "pa55w0rd"
        uncheck "I have read and accept the privacy statement"
      end

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
        fill_in "Password *", with: "pa55w0rd"
        fill_in "Confirm Password", with: "pa55w0rd"
        check "I have read and accept the privacy statement *"
      end

      it "should create a user" do
        expect { click_button submit }.to change(User, :count).by(1)
      end

      describe "after saving the user" do
        before { click_button submit }
        let(:user) { User.find_by_email('user@example.com') }

        it { is_expected.to have_title("#{user.last_name}, #{user.first_name}") }
        it { is_expected.to have_link('Sign out') }
      end
    end

  end

  describe "edit" do
    let(:user) { FactoryGirl.create(:user) }
    before do
      sign_in user
      visit edit_user_path(user, locale: :en) 
    end

    describe "page" do
      it { is_expected.to have_selector('h1', text: "Update your profile") }
      it { is_expected.to have_title("Edit user") }
      it { is_expected.to have_link('change', href: 'http://gravatar.com/emails') }
    end

    describe "with missing password confirmation" do
      before do
        fill_in "Password *", with: user.password
        click_button "Save changes"
      end

      it { is_expected.to have_content('error') }
    end

    describe "with valid information" do
      let(:new_first_name) { "New First Name" }
      let(:new_email) { "new@example.com" }
      before do
        fill_in "First name", with: new_first_name
        fill_in "E-Mail", with: new_email
        fill_in "Password *", with: user.password
        fill_in "Confirm Password", with: user.password
        click_button "Save changes"
      end

      it { is_expected.to have_title("#{user.last_name}, #{new_first_name}") }
      it { is_expected.to have_selector('div.alert.alert-success') }
      it { is_expected.to have_link('Sign out', href: signout_path(locale: :en)) }
      specify { expect(user.reload.first_name).to eq(new_first_name) }
      specify { expect(user.reload.email).to eq(new_email) }
    end
  end
end
