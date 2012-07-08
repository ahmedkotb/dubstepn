Dubstepn::Application.routes.draw do
  get "/" => "home#index"
  get "/resume" => "home#resume"
  get "/admin" => "home#admin"
  get "/login" => "home#login"
  get "/logout" => "home#logout"
  post "/credentials" => "home#credentials"
end
