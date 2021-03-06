FactoryGirl.define do
  factory :user do
    sequence(:first_name) { |n| "First #{n}" }
    sequence(:last_name) { |n| "Last #{n}" }
    sequence(:street) { |n| "Street #{n}" }
#    street "Street #{Time.now.to_i}" # street "Street 23"
    zip_code "12345"
    town "Town"
    country "Canada"
    sequence(:phone) { |n| "#{Time.now.to_i}#{n}" }
#    phone "#{Time.now.to_i}" # "12345678"
    sequence(:email) { |n| "first_#{n}@example.com" }
    password "pa55w0rd"
    password_confirmation "pa55w0rd"
    news true
    preferred_language "en"
    privacy_statement true

    factory :admin do
      admin true
    end

    factory :operator do
      operator true
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

  factory :list do
    sequence(:list_number) { |n| n }
    sequence(:registration_code) { |n| "#{n}abcde" }
    container "red"
    event

    factory :assigned do
      user
    end

    factory :accepted do
      user
      accepted_on Time.now
    end
  end

  factory :item do
    sequence(:item_number) { |n| n }
    sequence(:description) { |n| "My item number #{n}" }
    sequence(:size)        { |n| "#{n}00" }
    sequence(:price)       { |n| n }
    list
  end

  factory :news_translation do
    language "en"
    title "Title of news"
    description "Description of news"
    news
  end

  factory :news do
    sequence(:issue) { |n| "#{n}/2013" }
    user
    promote_to_frontpage true
    released true 
  end
end
