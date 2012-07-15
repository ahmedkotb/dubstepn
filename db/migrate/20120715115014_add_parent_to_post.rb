class AddParentToPost < ActiveRecord::Migration
  def change
    add_column :posts, :parent, :int
  end
end
