Given /^a user visits the signin page$/ do
  visit signin_path
end

When /^he submits invalid signin information$/ do
  click_button "Sign in"
end

Then /^he should see an error message$/ do
  page.should have_selector('div.alert.alert-error')
end

Given /^the user has an account$/ do
  @user = User.create(first_name: "Example", last_name: "User", street: "Street 123", zip_code: "12345", town: "Town", country: "Country", phone: "1234567", email: "user@example.com", password: "pa55w0rd", password_confirmation: "pa55w0rd")
end

When /^he submits valid signin information$/ do
  fill_in "E-Mail", with: @user.email
  fill_in "Password", with: @user.password
  click_button "Sign in"
end

Then /^he should see his profile page$/ do
  page.should have_title("#{@user.last_name}, #{@user.first_name}")
end

Then /^he should see a signout link$/ do
  page.should have_link('Sign out', href: signout_path)
end
