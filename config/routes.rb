Dubstepn::Application.routes.draw do
  # public routes
  get "/" => "home#index"
  get "/post/:post_id" => "home#post"
  get "/tag/:tag" => "home#index"
  get "/projects" => "home#index", :tag => "project"
  get "/resume" => "home#resume"

  # admin panel
  get "/admin" => "home#admin"
  get "/edit_post/:post_id" => "home#edit_post"
  post "/create_post" => "home#create_post_action"
  post "/edit_post" => "home#edit_post_action"
  post "/delete_post" => "home#delete_post_action"

  # authentication
  get "/login" => "home#login"
  post "/login" => "home#login_action"
  post "/logout" => "home#logout_action"
end
