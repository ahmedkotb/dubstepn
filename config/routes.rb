include ApplicationHelper

Dubstepn::Application.routes.draw do
  # public routes
  get "/" => "home#index"
  get "/post/:post_id" => "home#post", :format => false
  get "/resume" => "home#resume"
  get "/resume.pdf" => "home#resume"

  # indexing and syndication
  get "/robots" => "home#robots"
  get "/robots.txt" => "home#robots"
  get "/sitemap" => "home#sitemap"
  get "/sitemap.xml" => "home#sitemap"
  get "/rss" => "home#feed", :type => :rss
  get "/atom" => "home#feed", :type => :atom

  # admin panel
  get "/admin" => "home#admin"
  get "/edit_post/:post_id" => "home#edit_post", :format => false
  post "/create_post" => "home#create_post_action"
  post "/move_up" => "home#move_up_action"
  post "/move_down" => "home#move_down_action"
  post "/edit_post" => "home#edit_post_action"
  post "/delete_post" => "home#delete_post_action"

  # authentication
  get "/login" => "home#login"
  post "/login" => "home#login_action"
  post "/logout" => "home#logout_action"

  # legacy routes
  get "/p/self-balancing-electric-unicycle.html" => redirect("/post/17")
  get "/unicycle" => redirect("/post/17")
  get "/bullet" => redirect("/post/17")
  get "/2011/11/algebraic-data-types.html" => redirect("/post/18")
  get "/2011/10/monads-part-2.html" => redirect("/post/10")
  get "/2011/10/monads.html" => redirect("/post/9")
  get "/2011/09/uniqueness-types-and-godel.html" => redirect("/post/8")
  get "/2011/08/kicked-in-monads.html" => redirect("/post/7")
  get "/2011/08/great-war.html" => redirect("/post/6")
  get "/2011/08/welcome.html" => redirect("/post/5")
  get "/feeds/posts/default?alt=rss" => "home#blogger_feed"
  get "/feeds/posts/default" => "home#blogger_feed"

  # filters
  get "/:tag/:page" => "home#index", :format => false
  get "/*tag" => "home#index", :page => "1", :format => false # catch-all
end
