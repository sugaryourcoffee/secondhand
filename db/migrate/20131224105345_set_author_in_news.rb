class SetAuthorInNews < ActiveRecord::Migration
  class User < ActiveRecord::Base
  end
  class News < ActiveRecord::Base
    belongs_to :user
  end

  def up
    author = User.find_by_admin(true)
    News.update_all(user_id: author.id)
  end

  def down
    News.update_all(user_id: nil)
  end
end
