include ApplicationHelper
require 'date'
require 'digest'
require 'open-uri'

class HomeController < ApplicationController
  def index
    record_route("index")
    posts_per_page = 5
    @tag = if params[:tag] then params[:tag] else "home" end
    @filtered_posts = Post.order("sort_id DESC").select { |post| post.tags.map{ |tag| tag.name }.include?(@tag) }
    @page = params[:page].to_i
    @pages = (@filtered_posts.size+posts_per_page-1)/posts_per_page
    @filtered_posts = @filtered_posts[(@page-1)*posts_per_page, posts_per_page]
    @logged_in = is_logged_in
  end

  def post
    record_route("post["+params[:post_id].to_i.to_s+"]")
    @post = Post.find(params[:post_id].to_i)
    if !@post.is_public && !is_logged_in
      flash[:error] = "That post does not exist."
      return backtrack("login")
    end
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
    @posts = Post.order("sort_id DESC").all
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
    record_route("admin")
    post = Post.create(:title => "New Post", :content => "", :content_html => "", :is_public => false, :sort_id => 1)
    post.tags.create :name => "home"
    post.sort_id = post.id
    post.save!
    flash[:notice] = "New post created."
    return redirect_to "/edit_post/"+post.id.to_s
  end

  def move_up_action
    if !is_logged_in
      return redirect_to "/login"
    end
    record_route("admin")
    post1 = Post.find(params[:post_id].to_i)
    post2 = Post.where("sort_id > ?", post1.sort_id).order("sort_id ASC").first
    if post1 && post2
      post1_sort_id = post1.sort_id
      post1.sort_id = post2.sort_id
      post2.sort_id = post1_sort_id
      post1.save!
      post2.save!
    end
    return backtrack("login")
  end

  def move_down_action
    if !is_logged_in
      return redirect_to "/login"
    end
    record_route("admin")
    post1 = Post.find(params[:post_id].to_i)
    post2 = Post.where("sort_id < ?", post1.sort_id).order("sort_id DESC").first
    if post1 && post2
      post1_sort_id = post1.sort_id
      post1.sort_id = post2.sort_id
      post2.sort_id = post1_sort_id
      post1.save!
      post2.save!
    end
    return backtrack("login")
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
    post.content_html = markdown(post.content).gsub("<pre><code>", "<pre class=\"brush: python; toolbar: false;\">").gsub("</code></pre>", "</pre>").gsub("<h6>", "<p>").gsub("</h6>", "</p>").gsub("<h5>", "<p>").gsub("</h5>", "</p>").gsub("<h4>", "<h6>").gsub("</h4>", "</h6>").gsub("<h3>", "<h5>").gsub("</h3>", "</h5>").gsub("<h2>", "<h4>").gsub("</h2>", "</h4>").gsub("<h1>", "<h3>").gsub("</h1>", "</h3>")
    post.tags = params[:post_tags].downcase.split(",").map { |tag| tag.strip }.select { |tag| tag != "" }.map { |name| post.tags.create :name => name }
    post.is_public = !!params[:post_is_public]
    post.save!
    flash[:notice] = "The changes to the post entitled \""+post.title+"\" have been saved."
    return backtrack("login", "edit_post["+params[:post_id].to_i.to_s+"]")
  end

  def delete_post_action
    remove_routes("edit_post["+params[:post_id].to_i.to_s+"]")
    if !is_logged_in
      return redirect_to "/login"
    end
    record_route("admin")
    post = Post.find(params[:post_id].to_i)
    flash[:notice] = "The post entitled \""+post.title+"\" has been deleted."
    post.destroy
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