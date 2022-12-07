Rails.application.routes.draw do
  resources :parameters
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  root "pages#index", as: "home"

  get "about" => "pages#about", as: "about"

  get "help" => "pages#help", as: "help"

  post "save_to_xlsx" => "parameters#save_to_xlsx", as: "save_to_xlsx"
end
