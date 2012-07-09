include ApplicationHelper
require 'date'
require 'digest'
require 'open-uri'

class HomeController < ApplicationController
  before_filter :authenticate, :only => [:admin, :edit_post, :create_post_action, :edit_post_action, :delete_post_action]

  def index
    @posts = Post.order("created_at DESC").all
    if params[:tag]
      @posts = @posts.select { |post| post.tags.split(",").include?(params[:tag]) }
    end
    for post in @posts
      post.content = markdown(post.content).gsub("<pre>", "<pre class=\"brush: python\">").gsub("<code>", "").gsub("</code>", "")
    end
    @logged_in = is_logged_in
  end

  def post
    @post = Post.find(params[:post_id].to_i)
    if !@post.visible && !is_logged_in
      flash[:error] = "That post does not exist."
      return redirect_to "/"
    end
    @post.content = markdown(@post.content).gsub("<pre>", "<pre class=\"brush: python\">").gsub("<code>", "").gsub("</code>", "")
  end

  def resume
    data = open("http://s3.amazonaws.com/dubstepn/resume.pdf").read
    send_data data, :type => "application/pdf", :disposition => "inline"
  end

  def admin
    @posts = Post.order("created_at DESC").all
  end

  def edit_post
    @post = Post.find(params[:post_id].to_i)
  end

  def create_post_action
    post = Post.create(:title => "New Post", :content => "", :tags => "", :visible => false)
    flash[:notice] = "New post created."
    return redirect_to "/edit_post/"+post.id.to_s
  end

  def edit_post_action
    if params[:post_title].strip.size == 0
      flash[:error] = "Title cannot be empty."
      return redirect_to "/edit_post/"+params[:post_id]
    end
    post = Post.find(params[:post_id].to_i)
    post.title = params[:post_title]
    post.content = params[:post_content]
    post.tags = params[:post_tags].split(",").map { |tag| tag.strip }.join(",")
    post.visible = !!params[:post_visible]
    post.save!
    flash[:notice] = "The changes have been saved."
    return redirect_to "/edit_post/"+post.id.to_s
  end

  def delete_post_action
    flash[:notice] = "The post has been deleted."
    Post.destroy(params[:post_id].to_i)
    return redirect_to "/admin"
  end

  def login
  end

  def login_action
    if params[:password]
      if Digest::MD5.hexdigest(params[:password]) == "06b56586df6e470347ec246394d07172"
        session[:login_time] = DateTime.now
        flash[:notice] = "You are now logged in."
        return redirect_to "/admin"
      end
    end
    flash[:error] = "The password was incorrect."
    return redirect_to "/login"
  end

  def logout_action
    session[:login_time] = nil
    flash[:notice] = "You are now logged out."
    return redirect_to "/"
  end

  private
    def is_logged_in
      if session[:login_time] == nil
        return false
      end
      if session[:login_time].advance(:hours => 1) < DateTime.now
        return false
      end
      return true
    end

    def authenticate
      if !is_logged_in
        return redirect_to "/login"
      end
    end
end
