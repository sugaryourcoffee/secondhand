namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
    admin = User.create!(first_name: "Example",
                         last_name: "User",
                         street: "Street 123",
                         zip_code: "123452",
                         town: "Town",
                         country: "Country",
                         phone: "1213341",
                         email: "example@user.com",
                         password: "pa55w0rd",
                         password_confirmation: "pa55w0rd")
    admin.toggle!(:admin)
    99.times do |n|
      first_name = Faker::Name.first_name
      last_name = Faker::Name.last_name
      email = "example-#{n+1}@example.org"
      password = "password"
      User.create!(first_name: first_name,
                   last_name: last_name,
                   street: "Street #{100+n}",
                   zip_code: "1234#{n}",
                   town: "Town",
                   country: "Country",
                   phone: "#{n}12345",
                   email: email,
                   password: password,
                   password_confirmation: password)
    end
  end
end
