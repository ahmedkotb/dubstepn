class RenameVisibleInPosts < ActiveRecord::Migration
  def up
    change_table :posts do |t|
      t.rename :visible, :is_public
    end
  end

  def down
    change_table :posts do |t|
      t.rename :is_public, :visible
    end
  end
end
