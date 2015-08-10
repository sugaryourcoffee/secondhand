include ApplicationHelper

def valid_signin(user)
  fill_in "E-Mail", with: user.email
  fill_in "Password", with: user.password
  click_button "Sign in"
end

def sign_in(user)
  visit signin_path(locale: :en)
  fill_in "E-Mail", with: user.email
  fill_in "Password", with: user.password
  click_button "Sign in"
  cookies[:remember_token] = user.remember_token
end

def register_list(registration_code)
  #fill_in "Enter registration code. Note: 0 (number), O (letter)", with: registration_code
  fill_in "Enter registration code", with: registration_code
  click_button "Register List"
end

def log_test(message)
  Rails.logger.info(message)
  puts message
end

def user_for(list)
  user = list.user
  if user
    "#{user.last_name}, #{user.first_name}"
  else
    ""
  end
end

RSpec::Matchers.define :have_error_message do |message|
  match do |page|
    page.should have_selector('div.alert.alert-error', text: message)
  end
end
