Dubstepn::Application.routes.draw do
  get "/" => "home#index"
  get "/admin" => "home#admin"
end
