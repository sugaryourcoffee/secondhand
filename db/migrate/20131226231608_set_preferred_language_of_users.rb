class SetPreferredLanguageOfUsers < ActiveRecord::Migration
  class User < ActiveRecord::Base
  end

  def up
    User.update_all(preferred_language: "de")
  end

  def down
    User.update_all(preferred_language: nil)
  end
end
