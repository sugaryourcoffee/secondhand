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
    privacy_statement:     true, 
    password:              "password",
    password_confirmation: "password"
  }.merge(override)
end

def create_admin
  User.create!(user_attributes({first_name: "Jack",
                                last_name:  "Boss",
                                email:      "jack@example.com",
                                admin:      true}))
end

def create_operator
  User.create!(user_attributes({first_name: "Rita",
                                last_name:  "Operator",
                                email:      "rita@example.com",
                                operator:   true}))
end

def create_user
  User.create(user_attributes)
end
