class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :get_layout_fields

  private
    def get_layout_fields
      @posts = Post.order("created_at DESC").all
    end
end
