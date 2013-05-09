require 'spec_helper'

describe User do
  before {@user = User.new(first_name: "Example", last_name: "User", email: "user@example.com", street: "Street 1", zip_code: "12345", town: "Town", country: "Country", phone: "1234 567890", news: false, password: "foobar", password_confirmation: "foobar")}
subject {@user}
  it {should respond_to(:first_name) }
  it {should respond_to(:last_name) }
  it {should respond_to(:email) }
  it {should respond_to(:street) }
  it {should respond_to(:zip_code) }
  it {should respond_to(:town) }
  it {should respond_to(:country) }
  it {should respond_to(:phone) }
  it {should respond_to(:news) }
  it {should respond_to(:password_digest) }
  it {should respond_to(:password) }
  it {should respond_to(:password_confirmation) }
  it {should respond_to(:remember_token) }
  it {should respond_to(:authenticate) }

  it {should be_valid }

  describe "remember token" do
    before { @user.save }
    its(:remember_token) { should_not be_blank }
  end

  describe "when first_name is not present" do
    before {@user.first_name = " "}
    it {should_not be_valid}
  end
  describe "when last_name is not present" do
    before {@user.last_name = " "}
    it {should_not be_valid}
  end
  describe "when email is not present" do
    before {@user.email = " "}
    it {should_not be_valid}
  end
  describe "when street is not present" do
    before {@user.street = " "}
    it {should_not be_valid}
  end
  describe "when zip_code is not present" do
    before {@user.zip_code = " "}
    it {should_not be_valid}
  end
  describe "when town is not present" do
    before {@user.town = " "}
    it {should_not be_valid}
  end
  describe "when country is not present" do
    before {@user.country = " "}
    it {should_not be_valid}
  end
  describe "when phone is not present" do
    before {@user.phone = " "}
    it {should_not be_valid}
  end
  describe "when password is not present" do
    before {@user.password = @user.password_confirmation = " "}
    it {should_not be_valid}
  end

  describe "when email format is invalid" do
    it "should be invalid" do
      addresses = %w{user@foo,com user_at_foo.org example.user@foo. foo@bar_baz.com foo@bar+baz.com}
      addresses.each do |invalid_address|
        @user.email = invalid_address
        @user.should_not be_valid
      end
    end 
  end

  describe "when email format is valid" do
    it "should be valid" do
      addresses = %w{user@foo.COM A_US-ER@f.b.org first.last@foo.jp a+b@baz.cn}
      addresses.each do |valid_address|
        @user.email = valid_address
        @user.should be_valid
      end
    end
  end

  describe "when email address is already taken" do
    before do
      user_with_same_email = @user.dup
      user_with_same_email.email = @user.email.upcase
      user_with_same_email.save
    end
    it {should_not be_valid}
  end

  describe "when password doesn't match confirmation" do
    before {@user.password_confirmation = "mismatch"}
    it {should_not be_valid}
  end

  describe "when password confirmation is nil" do
    before {@user.password_confirmation = nil}
    it {should_not be_valid}
  end

  describe "with a password that is too short" do
    before {@user.password = @user.password_confirmation = "a" * 5}
    it {should be_invalid}
  end

  describe "return value of authenticate method" do
    before {@user.save}
    let(:found_user) {User.find_by_email(@user.email)}

    describe "with valid password" do
      it {should == found_user.authenticate(@user.password) }
    end

    describe "with invalid password" do
      let(:user_for_invalid_password) {found_user.authenticate("invalid") }

      it {should_not == user_for_invalid_password }
      specify {user_for_invalid_password.should be_false }
    end
  end
end
