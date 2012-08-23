include ApplicationHelper

class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :get_layout_fields

  private
    def get_layout_fields
      @recent_posts = Post.order("sort_id DESC").select { |post| post.tags.map{ |tag| tag.name }.include?("home") }.first(5)
      @sidebar_posts = Post.order("sort_id DESC").select { |post| post.tags.map{ |tag| tag.name }.include?("sidebar") }
      for post in @sidebar_posts
        post.content = markdown(post.content).gsub("<pre><code>", "<pre class=\"brush: python; toolbar: false;\">").gsub("</code></pre>", "</pre>").gsub("<h6>", "<p>").gsub("</h6>", "</p>").gsub("<h5>", "<p>").gsub("</h5>", "</p>").gsub("<h4>", "<h6>").gsub("</h4>", "</h6>").gsub("<h3>", "<h5>").gsub("</h3>", "</h5>").gsub("<h2>", "<h4>").gsub("</h2>", "</h4>").gsub("<h1>", "<h3>").gsub("</h1>", "</h3>")
      end
    end
end
