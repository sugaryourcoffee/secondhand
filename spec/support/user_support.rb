def user_attributes(override = {})
  {
    first_name:            "Example",
    last_name:             "User",
    email:                 "user@example.com",
    street:                "Street 12",
    zip_code:              "12345",
    town:                  "Town",
    country:               "Country",
    phone:                 "123 4567",
    password:              "password",
    password_confirmation: "password"
  }.merge(override)
end

def create_admin
  create_user.toggle!(:admin)
end

def create_user
  User.create(user_attributes)
end
