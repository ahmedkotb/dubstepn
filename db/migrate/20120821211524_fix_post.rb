include ApplicationHelper

class FixPost < ActiveRecord::Migration
  def up
    Post.all.each do |post|
      post.update_attributes!(:content_html => markdown(post.content).gsub("<pre><code>", "<pre class=\"brush: python; toolbar: false;\">").gsub("</code></pre>", "</pre>").gsub("<h6>", "<p>").gsub("</h6>", "</p>").gsub("<h5>", "<p>").gsub("</h5>", "</p>").gsub("<h4>", "<h6>").gsub("</h4>", "</h6>").gsub("<h3>", "<h5>").gsub("</h3>", "</h5>").gsub("<h2>", "<h4>").gsub("</h2>", "</h4>").gsub("<h1>", "<h3>").gsub("</h1>", "</h3>"))
    end
    change_column :posts, :content_html, :text, :null => false
  end

  def down
    change_column :posts, :content_html, :text
  end
end
