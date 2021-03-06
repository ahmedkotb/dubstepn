Dubstepn::Application.routes.draw do
  # public routes
  root "home#posts_for_tag"
  get "/post/:post_id/*title" => "home#post", :format => false
  get "/post/:post_id" => "home#post", :format => false
  get "/resume" => "home#resume"
  get "/resume.pdf" => "home#resume"

  # for web crawlers and search engines
  get "/robots.txt" => "home#robots"
  get "/sitemap" => "home#sitemap"

  # syndication
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
  post "/move_top" => "home#move_top_action"
  post "/move_bottom" => "home#move_bottom_action"
  post "/edit_post" => "home#edit_post_action"
  post "/delete_post" => "home#delete_post_action"
  post "/create_redirect" => "home#create_redirect_action"
  post "/delete_redirect" => "home#delete_redirect_action"

  # authentication
  get "/login" => "home#login"
  post "/login" => "home#login_action"
  post "/logout" => "home#logout_action"

  # tags
  get "/home" => redirect("/")
  get "/home/1" => redirect("/")
  get "/:tag/:page" => "home#posts_for_tag", :format => false
  get "/*tag" => "home#catch_all", :format => false # also used for custom redirects
end
