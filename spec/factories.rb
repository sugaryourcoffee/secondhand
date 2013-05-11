FactoryGirl.define do
  factory :user do
    sequence(:first_name) { |n| "First #{n}" }
    sequence(:last_name) { |n| "Last #{n}" }
    street "Street 23"
    zip_code "12345"
    town "Town"
    country "Canada"
    phone "12345678"
    sequence(:email) { |n| "first_#{n}@example.com" }
    password "pa55w0rd"
    password_confirmation "pa55w0rd"
  end
end
