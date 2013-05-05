# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  first_name      :string(255)
#  last_name       :string(255)
#  street          :string(255)
#  zip_code        :string(255)
#  town            :string(255)
#  country         :string(255)
#  phone           :string(255)
#  email           :string(255)
#  password_digest :string(255)
#  news            :boolean
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
