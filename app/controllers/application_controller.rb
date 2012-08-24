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
    end
end
