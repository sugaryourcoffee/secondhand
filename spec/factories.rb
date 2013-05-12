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

    factory :admin do
      admin true
    end
  end

  factory :event do
    title "Herbstboerse Burgthann"
    sequence(:event_date) { |n| "20#{n}-09-03" }
    location "Mittelschule Burgthann"
    fee 3
    deduction 20
    provision 15
    max_lists 10
    max_items_per_list 5
    active false

    factory :active do
      active true
    end
  end
end
