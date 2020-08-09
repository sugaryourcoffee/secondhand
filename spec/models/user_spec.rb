require 'spec_helper'

describe User do
  before {@user = User.new(first_name: "Example", 
                           last_name: "User", 
                           email: "user@example.com",
                           street: "Street 1",
                           zip_code: "12345",
                           town: "Town",
                           country: "Country",
                           phone: "1234 567890",
                           news: false,
                           password: "foobar",
                           password_confirmation: "foobar",
                           privacy_statement: true,
                           deactivated: false)}
subject {@user}
  it {is_expected.to respond_to(:first_name) }
  it {is_expected.to respond_to(:last_name) }
  it {is_expected.to respond_to(:email) }
  it {is_expected.to respond_to(:street) }
  it {is_expected.to respond_to(:zip_code) }
  it {is_expected.to respond_to(:town) }
  it {is_expected.to respond_to(:country) }
  it {is_expected.to respond_to(:phone) }
  it {is_expected.to respond_to(:news) }
  it {is_expected.to respond_to(:password_digest) }
  it {is_expected.to respond_to(:password) }
  it {is_expected.to respond_to(:password_confirmation) }
  it {is_expected.to respond_to(:remember_token) }
  it {is_expected.to respond_to(:authenticate) }
  it {is_expected.to respond_to(:admin) }
  it {is_expected.to respond_to(:operator) }
  it {is_expected.to respond_to(:preferred_language) }
  it {is_expected.to respond_to(:privacy_statement) }
  it {is_expected.to respond_to(:deactivated) }

  it {is_expected.to be_valid }
  it {is_expected.not_to be_admin }

  describe "with admin attribute set to 'true'" do
    before { @user.toggle!(:admin) }

    it { is_expected.to be_admin }
  end

  describe "remember token" do
    before { @user.save }
    it { expect(@user.remember_token).not_to be_blank }
#    its(:remember_token) { should_not be_blank }
  end

  describe "when first_name is not present" do
    before {@user.first_name = " "}
    it {is_expected.not_to be_valid}
  end
  describe "when last_name is not present" do
    before {@user.last_name = " "}
    it {is_expected.not_to be_valid}
  end
  describe "when email is not present" do
    before {@user.email = " "}
    it {is_expected.not_to be_valid}
  end
  describe "when street is not present" do
    before {@user.street = " "}
    it {is_expected.not_to be_valid}
  end
  describe "when zip_code is not present" do
    before {@user.zip_code = " "}
    it {is_expected.not_to be_valid}
  end
  describe "when town is not present" do
    before {@user.town = " "}
    it {is_expected.not_to be_valid}
  end
  describe "when country is not present" do
    before {@user.country = " "}
    it {is_expected.not_to be_valid}
  end
  describe "when phone is not present" do
    before {@user.phone = " "}
    it {is_expected.not_to be_valid}
  end
  describe "when password is not present" do
    before {@user.password = @user.password_confirmation = " "}
    it {is_expected.not_to be_valid}
  end
  describe "when password is empty" do
    before {@user.password.clear; @user.password_confirmation.clear}
    it {is_expected.to be_valid}
  end
  
  describe "when email format is invalid" do
    it "should be invalid" do
      addresses = %w{user@foo,com user_at_foo.org example.user@foo. foo@bar_baz.com foo@bar+baz.com}
      addresses.each do |invalid_address|
        @user.email = invalid_address
        expect(@user).not_to be_valid
      end
    end 
  end

  describe "when email format is valid" do
    it "should be valid" do
      addresses = %w{user@foo.COM A_US-ER@f.b.org first.last@foo.jp a+b@baz.cn}
      addresses.each do |valid_address|
        @user.email = valid_address
        expect(@user).to be_valid
      end
    end
  end

  describe "when email address is already taken" do
    before do
      user_with_same_email = @user.dup
      user_with_same_email.email = @user.email.upcase
      user_with_same_email.save
    end
    it {is_expected.not_to be_valid}
  end

  describe "when password doesn't match confirmation" do
    before {@user.password_confirmation = "mismatch"}
    it {is_expected.not_to be_valid}
  end

  describe "when password confirmation is nil" do
    before {@user.password_confirmation = nil}
    it {is_expected.to be_valid}
  end

  describe "when password is updated and password_confirmation is nil" do
    before { @user.password = "foo" }
    it {is_expected.not_to be_valid} 
  end

  describe "with a password that is too short" do
    before {@user.password = @user.password_confirmation = "a" * 5}
    it {is_expected.to be_invalid}
  end

  describe "return value of authenticate method" do
    before {@user.save}
    let(:found_user) {User.find_by_email(@user.email)}

    describe "with valid password" do
      it {is_expected.to eq(found_user.authenticate(@user.password)) }
    end

    describe "with invalid password" do
      let(:user_for_invalid_password) {found_user.authenticate("invalid") }

      it {is_expected.not_to eq(user_for_invalid_password) }
      specify {expect(user_for_invalid_password).to be_falsey }
    end
  end

  describe "search user by name" do
    before { @user.save }
    it { is_expected.to eq(User.search("Example")[0]) }
    it { is_expected.to eq(User.search("example")[0]) }
    it { is_expected.to eq(User.search("User")[0]) }
    it { is_expected.to eq(User.search("ser")[0]) }    
  end

  describe "deactivate user" do
    before { @user.news = true }
    it "should scrample user data" do
      original = @user.dup

      @user.deactivate

      expect(@user.first_name).not_to    eq original.first_name
      expect(@user.last_name).not_to     eq original.last_name
      expect(@user.email).not_to         eq original.email
      expect(@user.street).not_to        eq original.street
      expect(@user.news).to              be_falsey
      expect(@user.phone).not_to         eq original.phone
      expect(@user.privacy_statement).to be_falsey
      expect(@user.deactivated).to       be_truthy
    end
  end
end
