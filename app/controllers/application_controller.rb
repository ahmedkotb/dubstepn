include ApplicationHelper

class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :fix_host, :set_layout_data

  private
    # in production, permanently redirect if we aren't hitting the right hostname
    def fix_host
      if Rails.env.production? && request.host != APP_HOST
        redirect_to "#{ request.protocol }#{ APP_HOST }#{ request.fullpath }", :status => 301
      end
    end

    # set up the variables needed by the layout
    def set_layout_data
      banner_tag = Tag.where(:name => "banner").first
      if banner_tag
        @banner_posts = banner_tag.posts.order("sort_id DESC")
        if !is_logged_in
          @banner_posts = @banner_posts.where(:is_public => true)
        end
      else
        @banner_posts = []
      end
    end
end
