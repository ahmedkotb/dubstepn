Dubstepn::Application.routes.draw do
  get "/" => "home#index"
  get "/resume" => "home#resume"
  get "/admin" => "home#admin"
  get "/login" => "home#login"
  post "/credentials" => "home#credentials"
end
