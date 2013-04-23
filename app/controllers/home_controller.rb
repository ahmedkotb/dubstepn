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
    @tag = nil
    @posts = nil
    @page = nil
    @pages = nil
    begin
      @tag = Tag.where(:name => (if params[:tag] then params[:tag] else "home" end)).first!
      posts = if @logged_in then @tag.posts else @tag.posts.where(:is_public => true) end
      @pages = (posts.size + posts_per_page - 1) / posts_per_page
      @page = if params[:page] then Integer(params[:page], 10) else 1 end
      if @page < 1 || @page > @pages
        @page = nil
        raise
      end
      @posts = posts.order("sort_id DESC").limit(posts_per_page).offset((@page - 1) * posts_per_page)
    rescue
    end
    return render_404 if !@posts || @posts.size == 0
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
    return render_404 if !@post || (!@post.is_public && !@logged_in)
    if request.fullpath != @post.canonical_uri
      return redirect_to @post.canonical_uri, :status => 301
    end
  end

  def resume
    data = open("http://s3.amazonaws.com/dubstepn/resume.pdf").read
    send_data data, :type => "application/pdf", :disposition => "inline"
  end

  def robots
    robots = ""
    robots << "User-agent: *\r\n"
    robots << "Sitemap: http://" + APP_HOST + "/sitemap.xml\r\n"
    robots << "Disallow: /login\r\n"
    robots << "Disallow: /admin\r\n"
    robots << "Disallow: /resume\r\n"
    robots << "Disallow: /sidebar\r\n"
    sidebar_tag = Tag.where("name = ?", "sidebar").first
    if sidebar_tag
      for post in sidebar_tag.posts
        robots << "Disallow: " + post.canonical_uri + "\r\n"
      end
    end
    return render :text => robots
  end

  def sitemap
    sitemap = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\r\n"
    sitemap << "<urlset xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\">\r\n"
    sitemap << "  <url>\r\n"
    sitemap << "    <loc>http://" + APP_HOST + "</loc>\r\n"
    sitemap << "  </url>\r\n"
    Tag.all.each do |tag|
      if !["home", "sidebar"].include?(tag.name)
        sitemap << "  <url>\r\n"
        sitemap << "    <loc>http://" + APP_HOST + "/" + tag.name + "</loc>\r\n"
        sitemap << "  </url>\r\n"
      end
    end
    Post.all.each do |post|
      if post.is_public && !post.tags.map { |tag| tag.name }.include?("sidebar")
        sitemap << "  <url>\r\n"
        sitemap << "    <loc>http://" + APP_HOST + post.canonical_uri + "</loc>\r\n"
        sitemap << "  </url>\r\n"
      end
    end
    sitemap << "</urlset>\r\n"
    return render :xml => sitemap
  end

  def feed
    return render_feed(params[:type].to_sym)
  end

  def blogger_feed
    if params[:alt] == "rss"
      return redirect_to "/rss", :status => 301
    else
      return redirect_to "/atom", :status => 301
    end
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

  def render_404
    render "404", :status => 404
  end

  def render_feed(type)
    last_modified_date = Post.order("updated_at DESC").first.try(:created_at).try(:to_datetime) || DateTime.now
    case type
    when :rss
      tag = Tag.where(:name => "home").first
      posts = tag.posts.where(:is_public => true).order("sort_id DESC")
      rss = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\r\n"
      rss << "<rss version=\"2.0\" xmlns:atom=\"http://www.w3.org/2005/Atom\">\r\n"
      rss << "  <channel>\r\n"
      rss << "    <title>Stephan Boyer</title>\r\n"
      rss << "    <description>" + APP_DESCRIPTION.encode(:xml => :text) + "</description>\r\n"
      rss << "    <link>http://" + APP_HOST.encode(:xml => :text) + "/</link>\r\n"
      rss << "    <pubDate>" + last_modified_date.to_formatted_s(:rfc822).encode(:xml => :text) + "</pubDate>\r\n"
      rss << "    <atom:link href=\"http://" + APP_HOST.encode(:xml => :text) + "/rss\" rel=\"self\" type=\"application/rss+xml\" />\r\n"
      for post in posts
        rss << "    <item>\r\n"
        rss << "      <title>" + post.title.encode(:xml => :text) + "</title>\r\n"
        rss << "      <description>" + post.summary.encode(:xml => :text) + "</description>\r\n"
        rss << "      <link>http://" + APP_HOST.encode(:xml => :text) + post.canonical_uri.encode(:xml => :text) + "</link>\r\n"
        rss << "      <guid>http://" + APP_HOST.encode(:xml => :text) + post.canonical_uri.encode(:xml => :text) + "</guid>\r\n"
        rss << "      <pubDate>" + post.created_at.to_datetime.to_formatted_s(:rfc822).encode(:xml => :text) + "</pubDate>\r\n"
        rss << "    </item>\r\n"
      end
      rss << "  </channel>\r\n"
      rss << "</rss>\r\n"
      return render :xml => rss
    when :atom
      tag = Tag.where(:name => "home").first
      posts = tag.posts.where(:is_public => true).order("sort_id DESC")
      rss = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\r\n"
      rss << "<feed xmlns=\"http://www.w3.org/2005/Atom\">\r\n"
      rss << "  <title>Stephan Boyer</title>\r\n"
      rss << "  <subtitle>" + APP_DESCRIPTION.encode(:xml => :text) + "</subtitle>\r\n"
      rss << "  <link href=\"http://" + APP_HOST.encode(:xml => :text) + "/atom\" rel=\"self\" />\r\n"
      rss << "  <link href=\"http://" + APP_HOST.encode(:xml => :text) + "/\" />\r\n"
      rss << "  <id>http://" + APP_HOST.encode(:xml => :text) + "/</id>\r\n"
      rss << "  <updated>" + last_modified_date.to_formatted_s(:rfc3339).encode(:xml => :text) + "</updated>\r\n"
      for post in posts
        rss << "  <entry>\r\n"
        rss << "    <title>" + post.title.encode(:xml => :text) + "</title>\r\n"
        rss << "    <link href=\"http://" + APP_HOST.encode(:xml => :text) + "/atom\" rel=\"self\" />\r\n"
        rss << "    <link href=\"http://" + APP_HOST.encode(:xml => :text) + post.canonical_uri.encode(:xml => :text) + "\" />\r\n"
        rss << "    <id>http://" + APP_HOST.encode(:xml => :text) + post.canonical_uri.encode(:xml => :text) + "</id>\r\n"
        rss << "    <updated>" + post.created_at.to_datetime.to_formatted_s(:rfc3339).encode(:xml => :text) + "</updated>\r\n"
        rss << "    <summary>" + post.summary.encode(:xml => :text) + "</summary>\r\n"
        rss << "    <author>\r\n"
        rss << "      <name>" + APP_AUTHOR.encode(:xml => :text) + "</name>\r\n"
        rss << "      <email>" + APP_EMAIL.encode(:xml => :text) + "</email>\r\n"
        rss << "    </author>\r\n"
        rss << "  </entry>\r\n"
      end
      rss << "</feed>\r\n"
      return render :xml => rss
    end
  end
end
