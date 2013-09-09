begin
  Dubstepn::Application.routes.draw do
    # public routes
    root "home#index"
    get "/post/:post_id/*title" => "home#post", :format => false
    get "/post/:post_id" => "home#post", :format => false
    get "/resume" => "home#resume"
    get "/resume.pdf" => "home#resume"

    # indexing and syndication
    get "/robots.txt" => "home#robots"
    get "/sitemap" => "home#sitemap"
    get "/rss/home" => redirect("/rss")
    get "/rss" => "home#feed", :type => :rss
    get "/rss/:tag" => "home#feed", :type => :rss, :format => false
    get "/atom/home" => redirect("/atom")
    get "/atom" => "home#feed", :type => :atom
    get "/atom/:tag" => "home#feed", :type => :atom, :format => false

    # admin panel
    get "/admin" => "home#admin"
    get "/edit_post/:post_id" => "home#edit_post", :format => false
    post "/create_post" => "home#create_post_action"
    post "/move_up" => "home#move_up_action"
    post "/move_down" => "home#move_down_action"
    post "/edit_post" => "home#edit_post_action"
    post "/delete_post" => "home#delete_post_action"
    post "/create_redirect" => "home#create_redirect_action"
    post "/delete_redirect" => "home#delete_redirect_action"

    # authentication
    get "/login" => "home#login"
    post "/login" => "home#login_action"
    post "/logout" => "home#logout_action"

    # redirects
    for r in Redirect.all
      get r.from => redirect(r.to)
    end

    # filters
    get "/home" => redirect("/")
    get "/:tag/:page" => "home#index", :format => false
    get "/*tag" => "home#index", :page => "1", :format => false # catch-all
  end
rescue
  # if the "redirects" table isn't available (e.g. if we are rolling back the database), loading
  # this file will fail (because of line 37).  this should not be considered a fatal error,
  # because sometimes the database is not yet accessible when this file is loaded (e.g. when
  # running migrations on heroku).
  puts "ActiveRecord::StatementInvalid occurred, continuing anyway..."
end