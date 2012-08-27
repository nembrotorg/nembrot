Nembrot::Application.routes.draw do

  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'

  devise_for :users

  root :to => "home#index"

  resources :notes do
    resources :note_versions
  end

  resources :tags do
    resources :notes
  end

end
