class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :get_layout_fields

  private
    def get_layout_fields
      @posts = Post.order("created_at DESC").all
      @tags_hash = @posts.map { |post| post.tags.split(",").map { |tag| tag.strip } }.flatten.inject(Hash.new(0)) { |h, x|
        h[x] += 1
        h
      }
      @sorted_tags = @tags_hash.keys.sort { |a, b| @tags_hash[a] <=> @tags_hash[b] }
    end
end
