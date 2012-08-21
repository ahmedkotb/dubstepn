include ApplicationHelper
require 'date'
require 'digest'
require 'open-uri'

class HomeController < ApplicationController
  def index
    record_route("index")
    @posts = Post.order("id DESC").all
    tag = if params[:tag] then params[:tag] else "home" end
    @filtered_posts = @posts.select { |post| post.tags.map{ |tag| tag.name }.include?(tag) }
    for post in @filtered_posts
      post.content = markdown(post.content).gsub("<pre><code>", "<pre class=\"brush: python; toolbar: false;\">").gsub("</code></pre>", "</pre>").gsub("<h6>", "<p>").gsub("</h6>", "</p>").gsub("<h5>", "<p>").gsub("</h5>", "</p>").gsub("<h4>", "<h6>").gsub("</h4>", "</h6>").gsub("<h3>", "<h5>").gsub("</h3>", "</h5>").gsub("<h2>", "<h4>").gsub("</h2>", "</h4>").gsub("<h1>", "<h3>").gsub("</h1>", "</h3>")
    end
    @logged_in = is_logged_in
  end

  def post
    record_route("post["+params[:post_id].to_i.to_s+"]")
    @post = Post.find(params[:post_id].to_i)
    if !@post.is_public && !is_logged_in
      flash[:error] = "That post does not exist."
      return backtrack("login")
    end
    @post.content = markdown(@post.content).gsub("<pre><code>", "<pre class=\"brush: python; toolbar: false;\">").gsub("</code></pre>", "</pre>").gsub("<h6>", "<p>").gsub("</h6>", "</p>").gsub("<h5>", "<p>").gsub("</h5>", "</p>").gsub("<h4>", "<h6>").gsub("</h4>", "</h6>").gsub("<h3>", "<h5>").gsub("</h3>", "</h5>").gsub("<h2>", "<h4>").gsub("</h2>", "</h4>").gsub("<h1>", "<h3>").gsub("</h1>", "</h3>")
    @logged_in = is_logged_in
  end

  def resume
    record_route("resume")
    data = open("http://s3.amazonaws.com/dubstepn/resume.pdf").read
    send_data data, :type => "application/pdf", :disposition => "inline"
  end

  def admin
    record_route("admin")
    if !is_logged_in
      return redirect_to "/login"
    end
  end

  def edit_post
    if !is_logged_in
      return redirect_to "/login"
    end
    record_route("edit_post["+params[:post_id].to_i.to_s+"]")
    @post = Post.find(params[:post_id].to_i)
  end

  def create_post_action
    if !is_logged_in
      return redirect_to "/login"
    end
    post = Post.create(:title => "New Post", :content => "", :is_public => false)
    post.tags.create :name => "home"
    flash[:notice] = "New post created."
    return redirect_to "/edit_post/"+post.id.to_s
  end

  def edit_post_action
    if !is_logged_in
      return redirect_to "/login"
    end
    if params[:post_title].strip.size == 0
      flash[:error] = "Title cannot be empty."
      return redirect_to "/edit_post/"+params[:post_id]
    end
    post = Post.find(params[:post_id].to_i)
    post.tags.destroy_all
    post.title = params[:post_title]
    post.content = params[:post_content]
    post.tags = params[:post_tags].downcase.split(",").map { |tag| tag.strip }.select { |tag| tag != "" }.map { |name| post.tags.create :name => name }
    post.is_public = !!params[:post_is_public]
    post.save!
    flash[:notice] = "The changes have been saved."
    return backtrack("login", "edit_post["+params[:post_id].to_i.to_s+"]")
  end

  def delete_post_action
    remove_routes("edit_post["+params[:post_id].to_i.to_s+"]")
    if !is_logged_in
      return redirect_to "/login"
    end
    flash[:notice] = "The post has been deleted."
    Post.destroy(params[:post_id].to_i)
    return backtrack("login")
  end

  def login
    record_route("login")
  end

  def login_action
    if params[:password]
      if Digest::MD5.hexdigest(params[:password]) == "06b56586df6e470347ec246394d07172"
        session[:login_time] = DateTime.now
        flash[:notice] = "You are now logged in."
        remove_routes("login")
        return backtrack
      end
    end
    flash[:error] = "The password was incorrect."
    return backtrack
  end

  def logout_action
    session[:login_time] = nil
    flash[:notice] = "You are now logged out."
    remove_routes("admin", /edit_post\[.*\]/)
    return backtrack("login")
  end
end