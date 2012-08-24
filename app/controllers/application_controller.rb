include ApplicationHelper

class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :get_layout_fields

  private
    def get_layout_fields
      home_tag = Tag.where(:name => "home").first
      sidebar_tag = Tag.where(:name => "sidebar").first
      if is_logged_in
        @recent_posts = if home_tag then home_tag.posts.order("sort_id DESC").limit(5) else [] end
        @sidebar_posts = if sidebar_tag then sidebar_tag.posts.order("sort_id DESC") else [] end
      else
        @recent_posts = if home_tag then home_tag.posts.where(:is_public => true).order("sort_id DESC").limit(5) else [] end
        @sidebar_posts = if sidebar_tag then sidebar_tag.posts.where(:is_public => true).order("sort_id DESC") else [] end
      end
      for post in @sidebar_posts
        post.content = markdown(post.content).gsub("<pre><code>", "<pre class=\"brush: python; toolbar: false;\">").gsub("</code></pre>", "</pre>").gsub("<h6>", "<p>").gsub("</h6>", "</p>").gsub("<h5>", "<p>").gsub("</h5>", "</p>").gsub("<h4>", "<h6>").gsub("</h4>", "</h6>").gsub("<h3>", "<h5>").gsub("</h3>", "</h5>").gsub("<h2>", "<h4>").gsub("</h2>", "</h4>").gsub("<h1>", "<h3>").gsub("</h1>", "</h3>")
      end
    end
end
