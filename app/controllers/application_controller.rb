include ApplicationHelper

class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :get_layout_fields

  private
    def get_layout_fields
      @recent_posts = Post.order("id DESC").select { |post| post.tags.map{ |tag| tag.name }.include?("home") }.first(5)
    end
end
