class SetAllNilAttributesToNonNilInNews < ActiveRecord::Migration
  class News < ActiveRecord::Base
  end

  def up
    News.update_all({ promote_to_frontpage: true, 
                      released: true, 
                      issue: '2013' })
  end

  def down
    News.update_all({ promote_to_frontpage: false,
                      released: false,
                      issue: '' })
  end
end
