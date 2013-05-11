class AddJavascriptAndCssToPosts < ActiveRecord::Migration
  def up
    add_column :posts, :javascript, :text
    add_column :posts, :css, :text
    Post.all.each do |post|
      post.update_attributes!(:javascript => "")
      post.update_attributes!(:css => "")
    end
    change_column :posts, :javascript, :text, :null => false
    change_column :posts, :css, :text, :null => false
  end

  def down
    remove_column :posts, :css
    remove_column :posts, :javascript
  end
end
