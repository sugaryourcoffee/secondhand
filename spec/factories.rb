FactoryGirl.define do
  factory :user do
    first_name   "Pierre"
    last_name    "Sugar"
    street "Street 23"
    zip_code "12345"
    town "Town"
    country "Canada"
    phone "12345678"
    email  "pierre@sugaryourcoffee.de"
    password "pa55w0rd"
    password_confirmation "pa55w0rd"
  end
end
