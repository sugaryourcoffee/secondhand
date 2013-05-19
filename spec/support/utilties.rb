include ApplicationHelper

def valid_signin(user)
  fill_in "E-Mail", with: user.email
  fill_in "Password", with: user.password
  click_button "Sign in"
end

def sign_in(user)
  visit signin_path
  fill_in "E-Mail", with: user.email
  fill_in "Password", with: user.password
  click_button "Sign in"
  cookies[:remember_token] = user.remember_token
end

def register_list(registration_code)
  fill_in "Enter registration code:", with: registration_code
  click_button "Register List"
end

def log_test(message)
  Rails.logger.info(message)
  puts message
end

RSpec::Matchers.define :have_error_message do |message|
  match do |page|
    page.should have_selector('div.alert.alert-error', text: message)
  end
end
