Nembrot::Application.routes.draw do

	mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'

	devise_for :users

	root :to => "home#index"

  match 'notes/:id/v/:sequence' => 'notes#version'
  match 'tags/:slug' => 'tags#show'

	resources :notes do
		resources :v, :as => :versions
	end

	resources :tags

end
