Dubstepn::Application.routes.draw do
  get "/" => "home#index"
  get "/resume" => "home#resume"
  get "/admin" => "home#admin"
end
