class AddSortIdToPost < ActiveRecord::Migration
  def up
    add_column :posts, :sort_id, :integer
    Post.all.each do |post|
      post.update_attributes!(:sort_id => post.id)
    end
    change_column :posts, :sort_id, :integer, :null => false
  end

  def down
    remove_column :posts, :sort_id
  end
end
