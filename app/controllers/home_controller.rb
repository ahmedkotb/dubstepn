include ApplicationHelper
require 'date'
require 'digest'
require 'open-uri'

class HomeController < ApplicationController
  def index
    record_route("index")
    @posts = Post.order("created_at DESC").all
    if params[:tag]
      @posts = @posts.select { |post| post.tags.split(",").include?(params[:tag]) }
    end
    for post in @posts
      post.content = markdown(post.content).gsub("<pre><code>", "<pre class=\"brush: python; toolbar: false;\">").gsub("</code></pre>", "</pre>")
    end
    @logged_in = is_logged_in
  end

  def post
    record_route("post")
    @post = Post.find(params[:post_id].to_i)
    if !@post.visible && !is_logged_in
      flash[:error] = "That post does not exist."
      return backtrack("login")
    end
    @post.content = markdown(@post.content).gsub("<pre><code>", "<pre class=\"brush: python; toolbar: false;\">").gsub("</code></pre>", "</pre>")
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
    @posts = Post.order("created_at DESC").all
  end

  def edit_post
    if !is_logged_in
      return redirect_to "/login"
    end
    record_route("edit_post")
    @post = Post.find(params[:post_id].to_i)
  end

  def create_post_action
    if !is_logged_in
      return redirect_to "/login"
    end
    post = Post.create(:title => "New Post", :content => "", :tags => "", :visible => false)
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
    post.title = params[:post_title]
    post.content = params[:post_content]
    post.tags = params[:post_tags].downcase.split(",").map { |tag| tag.strip }.join(",")
    post.visible = !!params[:post_visible]
    post.save!
    flash[:notice] = "The changes have been saved."
    return backtrack("login", "edit_post")
  end

  def delete_post_action
    remove_routes("edit_post")
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
        return backtrack("login")
      end
    end
    flash[:error] = "The password was incorrect."
    return backtrack("login")
  end

  def logout_action
    session[:login_time] = nil
    flash[:notice] = "You are now logged out."
    return backtrack("login", "admin", "edit_post")
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

    def record_route(name)
      if request.get?
        if session[:routes] == nil
          session[:routes] = [[name, request.fullpath]]
        else
          session[:routes].push([name, request.fullpath])
        end
      end
    end

    def remove_routes(*blacklist)
      if session[:routes] != nil
        session[:routes].select! { |pair| !blacklist.include?(pair[0])}
      end
    end

    def backtrack(*blacklist)
      if session[:routes] != nil
        while session[:routes].size > 0
          pair = session[:routes].pop
          if !blacklist.include?(pair[0])
            return redirect_to pair[1]
          end
        end
      end
      return redirect_to "/"
    end
end
