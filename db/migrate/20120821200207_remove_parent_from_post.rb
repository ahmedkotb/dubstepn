class RemoveParentFromPost < ActiveRecord::Migration
  def up
    remove_column :posts, :parent_id
  end

  def down
    add_column :posts, :parent_id, :integer
  end
end
