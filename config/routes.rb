Gamerankr::Application.routes.draw do
  get "/search" => 'search#search'
  get "/my_games" => "rankings#mine"
  get "/my_shelf/:id" => "rankings#my_shelf", :as => :my_shelf
  
  resources :comments, :designers, :developers, :friends,
    :game_genres, :game_series, :genres, :manufacturers,
    :profile_questions, :publishers,
    :rankings, :ranking_shelves, :series, :shelves

  resources :rankings do
    resources :comments
  end
  
  resources :platforms do
    member do
      get 'merge'
      post 'merge'
    end
  end
  get "/platforms/generation/:generation", :to => "platforms#generation", :as => 'platform_generation'
  
  resources :games do
    member do
      post 'split', :to => 'games#split'
      get 'screenshots', :to => 'screenshots#game'
      get 'game_genres', :to => 'game_genres#game'
    end
  end
  resources :ports do
    member do
      post 'split', :to => 'ports#split'
      get 'cover'
    end
  end
  resources :users do
    member do
      get 'rankings', :to => 'rankings#user'
      get 'edit_email_preference'
    end
  end

  get '/contact', :to => 'contact#index'
  post '/contact', :to => 'contact#submit'
  
  get '/auth/:provider/callback', :to => 'sessions#create'
  get '/session/fake_sign_in/:id', :to => 'sessions#fake_sign_in'
  get '/about', :to => 'main#about'
  get '/dialog/feed', :to => 'dialog#feed'

  get "/search_and_edit" => "admin#search_and_edit"
  get "/amazon_ports" => "admin#amazon_ports"
  post "/multi_edit" => "admin#multi_edit"
  
  post '/bounce/bounce' => 'bounce#bounce'

  get '/sitemap', to: "site_map#index"
  get '/sitemap/games/:page', to: "site_map#games", as: "sitemap_games"
  get '/sitemap/users/:page', to: "site_map#users", as: "sitemap_users"
  get '/sitemap/shelves/:page', to: "site_map#shelves", as: "sitemap_shelves"
  get '/sitemap/platforms/:page', to: "site_map#platforms", as: "sitemap_platforms"
  get '/sitemap/manufacturers/:page', to: "site_map#manufacturers", as: "sitemap_manufacturers"
  get '/sitemap/rankings/:page', to: "site_map#rankings", as: "sitemap_rankings"
  get '/sitemap/misc', to: "site_map#misc", as: "sitemap_misc"

  root :to => "main#index"
end
