require 'spec_helper'

describe "Event users index page" do

 let(:hacker) { User.create!(user_attributes) } 
 let(:jane  ) { User.create!(user_attributes( { first_name: "Jane",
                                                email: "jane@example.com" 
                                              } )) }
 let(:operator) { create_operator }
 let(:admin)    { create_admin }

 context "with logged in user" do
   before { sign_in hacker }
   it "does not allow access to event users index page" do
     visit event_users_path(locale: :en)
     expect(page.current_path).to eq root_path(locale: :en)
     expect(page).to have_text "Requested page is not available"
   end
 end

 context "with logged in operator" do
   before { puts operator.inspect; sign_in operator }
   it "does not allow access to event users index page but gives hint" do
     visit event_users_path(locale: :en)
     expect(page.current_path).to eq root_path(locale: :en)
     expect(page).to have_text "Please contact your admin to access this page"
   end
 end

 context "with logged in admin" do
   before { sign_in admin }
   it "lets admin access event users index page" do
     visit event_users_path(locale: :en)
     expect(page.current_path).to eq event_users_path(locale: :en)
     expect(page).to have_text "List"
     expect(page).to have_text "Last Name"
     expect(page).to have_text "First Name"
     expect(page).to have_text "Address"
     expect(page).to have_text "E-Mail"
     expect(page).to have_text "Phone"
     expect(page).to have_text hacker.first_name
     expect(page).to have_text jane.first_name
   end
 end

end

