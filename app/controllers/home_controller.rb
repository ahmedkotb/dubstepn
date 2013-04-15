include ApplicationHelper
require 'date'
require 'digest'
require 'open-uri'

class HomeController < ApplicationController
  secure_actions = [:admin, :edit_post, :create_post_action, :move_up_action, :move_down_action, :edit_post_action, :delete_post_action, :login, :login_action, :logout_action]
  restricted_actions = [:admin, :edit_post, :create_post_action, :move_up_action, :move_down_action, :edit_post_action, :delete_post_action, :logout_action]
  before_filter :secure_page, :only => secure_actions
  before_filter :insecure_page
  skip_before_filter :insecure_page, :only => secure_actions
  before_filter :require_login, :only => restricted_actions

  def index
    posts_per_page = 5
    @logged_in = is_logged_in
    @tag_name = if params[:tag] then params[:tag] else "home" end
    @tag = Tag.where(:name => @tag_name).first
    @page = params[:page].to_i
    if @logged_in
      posts_with_tag = if @tag then @tag.posts else nil end
    else
      posts_with_tag = if @tag then @tag.posts.where(:is_public => true) else nil end
    end
    @filtered_posts = if posts_with_tag then posts_with_tag.order("sort_id DESC").limit(posts_per_page).offset((@page-1)*posts_per_page) else [] end
    @pages = if posts_with_tag then (posts_with_tag.size + posts_per_page-1)/posts_per_page else 0 end
  end

  def post
    @logged_in = is_logged_in
    @post = nil
    @previous = nil
    @next = nil
    begin
      @post = Post.find(params[:post_id].to_i)
      @previous = Tag.where(:name => "home").first.posts.where("sort_id < ? AND is_public = ?", @post.sort_id, true).order("sort_id DESC").first
      @next = Tag.where(:name => "home").first.posts.where("sort_id > ? AND is_public = ?", @post.sort_id, true).order("sort_id ASC").first
    rescue
    end
  end

  def resume
    data = open("http://s3.amazonaws.com/dubstepn/resume.pdf").read
    send_data data, :type => "application/pdf", :disposition => "inline"
  end

  def sitemap
    sitemap = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\r\n"
    sitemap << "<urlset xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\">\r\n"
    sitemap << "  <url>\r\n"
    sitemap << "    <loc>http://www.stephanboyer.com</loc>\r\n"
    sitemap << "  </url>\r\n"
    Tag.all.each do |tag|
      if !["home", "sidebar"].include?(tag.name)
        sitemap << "  <url>\r\n"
        sitemap << "    <loc>http://www.stephanboyer.com/" + tag.name + "</loc>\r\n"
        sitemap << "  </url>\r\n"
      end
    end
    Post.all.each do |post|
      if post.is_public && !post.tags.map { |tag| tag.name }.include?("sidebar")
        sitemap << "  <url>\r\n"
        sitemap << "    <loc>http://www.stephanboyer.com/post/" + post.id.to_s + "</loc>\r\n"
        sitemap << "  </url>\r\n"
      end
    end
    sitemap << "</urlset>\r\n"
    return render :xml => sitemap
  end

  def rss
    tag = Tag.where(:name => "home").first
    posts = tag.posts.where(:is_public => true).order("sort_id DESC")
    rss = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\r\n"
    rss << "<rss version=\"2.0\" xmlns:atom=\"http://www.w3.org/2005/Atom\">\r\n"
    rss << "  <channel>\r\n"
    rss << "    <title>Stephan Boyer</title>\r\n"
    rss << "    <description>Computer science et al.</description>\r\n"
    rss << "    <link>http://www.stephanboyer.com/</link>\r\n"
    rss << "    <language>en</language>\r\n"
    rss << "    <category>Computer science</category>\r\n"
    rss << "    <copyright>Copyright " + Time.new.year.to_s + " Stephan Boyer.  All Rights Reserved.</copyright>\r\n"
    rss << "    <atom:link href=\"http://www.stephanboyer.com/rss\" rel=\"self\" type=\"application/rss + xml\" />\r\n"
    for post in posts
      rss << "    <item>\r\n"
      rss << "      <title>" + post.title.encode(:xml => :text) + "</title>\r\n"
      rss << "      <description>" + post.title.encode(:xml => :text) + "</description>\r\n"
      rss << "      <link>http://www.stephanboyer.com/post/" + post.id.to_s + "</link>\r\n"
      rss << "      <guid>http://www.stephanboyer.com/post/" + post.id.to_s + "</guid>\r\n"
      rss << "      <pubDate>" + post.created_at.to_formatted_s(:rfc822).encode(:xml => :text) + "</pubDate>\r\n"
      rss << "    </item>\r\n"
    end
    rss << "  </channel>\r\n"
    rss << "</rss>\r\n"
    return render :xml => rss
  end

  def admin
    @posts = Post.order("sort_id DESC").all
    @tags = Tag.all
  end

  def edit_post
    @post = Post.find(params[:post_id].to_i)
  end

  def create_post_action
    post = Post.create(:title => "Untitled Post", :content => "", :content_html => "", :is_public => false, :sort_id => 1)
    post.tags = [Tag.get_tag_by_name("home")]
    post.sort_id = post.id
    post.save!
    flash[:notice] = "New post created."
    return redirect_to "/edit_post/" + post.id.to_s
  end

  def move_up_action
    post1 = Post.find(params[:post_id].to_i)
    post2 = Post.where("sort_id > ?", post1.sort_id).order("sort_id ASC").first
    if post1 && post2
      post1_sort_id = post1.sort_id
      post1.sort_id = post2.sort_id
      post2.sort_id = post1_sort_id
      post1.save!
      post2.save!
    end
    return redirect_to "/admin"
  end

  def move_down_action
    post1 = Post.find(params[:post_id].to_i)
    post2 = Post.where("sort_id < ?", post1.sort_id).order("sort_id DESC").first
    if post1 && post2
      post1_sort_id = post1.sort_id
      post1.sort_id = post2.sort_id
      post2.sort_id = post1_sort_id
      post1.save!
      post2.save!
    end
    return redirect_to "/admin"
  end

  def edit_post_action
    if params[:post_title].strip.size == 0
      flash[:error] = "Title cannot be empty."
      return redirect_to "/edit_post/" + params[:post_id]
    end
    post = Post.find(params[:post_id].to_i)
    while !post.tags.empty?
      Tag.unlink_tag_from_post(post, post.tags.first)
    end
    post.title = params[:post_title]
    post.content = params[:post_content]
    post.content_html = markdown(post.content)
    post.tags = params[:post_tags].downcase.split(",").map { |tag| tag.strip }.select { |tag| tag != "" }.map { |name| Tag.get_tag_by_name(name) }
    post.is_public = !!params[:post_is_public]
    post.save!
    flash[:notice] = "The changes to the post entitled \"" + post.title + "\" have been saved."
    return redirect_to "/edit_post/" + params[:post_id]
  end

  def delete_post_action
    post = Post.find(params[:post_id].to_i)
    flash[:notice] = "The post entitled \"" + post.title + "\" has been deleted."
    while !post.tags.empty?
      Tag.unlink_tag_from_post(post, post.tags.first)
    end
    post.destroy
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
  def secure_page
    if Rails.env.production? && request.protocol != "https://"
      return redirect_to "https://#{request.url[(request.protocol.size)..(-1)]}"
    end
  end

  def insecure_page
    if Rails.env.production? && request.protocol != "http://"
      return redirect_to "http://#{request.url[(request.protocol.size)..(-1)]}"
    end
  end

  def require_login
    if !is_logged_in
      return redirect_to "/login"
    end
  end
end
