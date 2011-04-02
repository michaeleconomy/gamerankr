Gamerankr::Application.routes.draw do
  match "/search" => 'search#search'
  match "/my_games" => "rankings#mine"
  match "/my_shelf/:id" => "rankings#my_shelf", :as => :my_shelf
  
  resources :comments, :designers, :developers, :friends,
    :rankings, :ranking_shelves, :platforms, :publishers, :shelves
  resources :games do
    member do
      get 'screenshots', :to => 'screenshots#game'
    end
  end
  resources :ports do
    member do
      get 'cover'
    end
  end
  resources :users do
    member do
      get 'rankings', :to => 'rankings#user'
    end
  end
  
  match '/auth/:provider/callback', :to => 'sessions#create'
  match '/session/fake_sign_in/:id', :to => 'sessions#fake_sign_in'
  match '/about', :to => 'main#about'
  root :to => "main#index"
end
