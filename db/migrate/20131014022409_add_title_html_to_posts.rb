include ApplicationHelper

class AddTitleHtmlToPosts < ActiveRecord::Migration
  def up
    add_column :posts, :title_html, :text
    remarkdown_all_posts!
    change_column :posts, :title_html, :text, :null => false
  end

  def down
    remove_column :posts, :title_html
  end
end
