Dubstepn::Application.routes.draw do
  # make sure all routes have www
  constraints(:host => "stephanboyer.com") do
    match "/" => redirect("http://www.stephanboyer.com")
    match "/*path" => redirect { |params| "http://www.stephanboyer.com/#{params[:path]}" }, :format => false
  end

  # public routes
  get "/" => "home#index", :page => "1"
  get "/page/:page" => "home#index"
  get "/post/:post_id" => "home#post"
  get "/tag/:tag" => "home#index", :page => "1"
  get "/tag/:tag/:page" => "home#index"
  get "/projects" => "home#index", :tag => "project", :page => "1"
  get "/resume" => "home#resume"

  # admin panel
  get "/admin" => "home#admin"
  get "/edit_post/:post_id" => "home#edit_post"
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
  match "/p/self-balancing-electric-unicycle.html" => redirect("/post/17")
  match "/2011/11/algebraic-data-types.html" => redirect("/post/18")
  match "/2011/10/monads-part-2.html" => redirect("/post/10")
  match "/2011/10/monads.html" => redirect("/post/9")
  match "/2011/09/uniqueness-types-and-godel.html" => redirect("/post/8")
  match "/2011/08/kicked-in-monads.html" => redirect("/post/7")
  match "/2011/08/great-war.html" => redirect("/post/6")
  match "/2011/08/welcome.html" => redirect("/post/5")
end
