class FixTag < ActiveRecord::Migration
  def up
    change_column :tags, :name, :string, :null => false
    change_column :posts_tags, :post_id, :integer, :null => false
    change_column :posts_tags, :tag_id, :integer, :null => false
  end

  def down
    change_column :tags, :name, :string
    change_column :posts_tags, :post_id, :integer
    change_column :posts_tags, :tag_id, :integer
  end
end
