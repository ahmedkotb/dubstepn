class RenameParentInPosts < ActiveRecord::Migration
  def up
    change_table :posts do |t|
      t.rename :parent, :parent_id
    end
  end

  def down
    change_table :posts do |t|
      t.rename :parent_id, :parent
    end
  end
end
